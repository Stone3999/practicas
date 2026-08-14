import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/rack.dart';
import '../models/rack_sensor_data.dart';
import '../services/api_service.dart';
import '../services/rack_link_client.dart';

class RackProvider with ChangeNotifier {
  final RackLinkClient _linkClient = RackLinkClient();
  final ApiService _apiService = ApiService();

  // logica
  // logica
  static const List<String> dataCenters = ['A', 'B', 'C', 'D'];

  LinkState _connectionState = LinkState.disconnected;
  LinkState get connectionState => _connectionState;

  RackSensorData? _currentData;
  RackSensorData? get currentData => _currentData;

  List<Rack> _racks = [];
  List<Rack> get racks => _racks;

  String _dataCenter = 'A';
  String get dataCenter => _dataCenter;

  String _selectedRackId = 'DC-A-RACK-01';
  String get selectedRackId => _selectedRackId;

  List<dynamic> _alerts = [];
  List<dynamic> get alerts => _alerts;

  Timer? _sessionTimer;

  RackProvider() {
    final envRack = dotenv.env['DEFAULT_RACK_ID'] ?? 'DC-A-RACK-01';
    _selectedRackId = envRack;
    _dataCenter = _dcFromRackId(envRack);
    _init();
  }

  String _dcFromRackId(String rackId) {
    final match = RegExp(r'^DC-([A-Za-z])-').firstMatch(rackId);
    return match?.group(1)?.toUpperCase() ?? 'A';
  }

  void _init() {
    _linkClient.stateStream.listen((state) {
      _connectionState = state;
      notifyListeners();
    });

    _linkClient.dataStream.listen((data) {
      _currentData = data;
      notifyListeners();
    });

    // logica
    // logica
    _sessionTimer = Timer.periodic(const Duration(seconds: 2), (_) => _syncSession());
    fetchRacks();
  }

  // logica
  // logica
  /// Consulta el estado compartido (backend) y refleja aquí lo que haya
  /// cambiado desde el reloj: si el reloj se detuvo, este celular también
  /// se desconecta; si el reloj cambió de rack, este celular lo sigue.
  Future<void> _syncSession() async {
    final session = await _apiService.getSession();
    if (session == null) return;

    final remoteRackId = session['activeRackId'] as String?;
    final remoteLinked = session['linked'] as bool? ?? false;

    if (remoteRackId != null && remoteRackId != _selectedRackId) {
      _selectedRackId = remoteRackId;
      _dataCenter = _dcFromRackId(remoteRackId);
      if (_connectionState != LinkState.disconnected) {
        await _linkClient.connect(_selectedRackId);
      }
      notifyListeners();
    }

    final isLocallyLinked = _connectionState != LinkState.disconnected;
    if (!remoteLinked && isLocallyLinked) {
      _linkClient.disconnect();
    }
  }

  Future<void> fetchRacks() async {
    _racks = await _apiService.getRacks();
    notifyListeners();
  }

  Future<void> fetchAlerts() async {
    _alerts = await _apiService.getAlerts();
    notifyListeners();
  }

  // logica
  // logica
  /// Cambia el Data Center a monitorear (usa el Rack 1 de ese DC). Si ya
  /// estábamos conectados, empuja el cambio al instante para que el reloj
  /// lo siga sin esperar el siguiente ciclo de sincronización.
  Future<void> selectDataCenter(String dc) async {
    _dataCenter = dc;
    _selectedRackId = 'DC-$dc-RACK-01';
    notifyListeners();

    if (_connectionState != LinkState.disconnected) {
      await _apiService.updateSession(activeRackId: _selectedRackId);
      await _linkClient.connect(_selectedRackId);
    }
  }

  /// Botón único "Conectar": vincula el celular al rack seleccionado
  /// leyéndolo directo del backend por IP local, y marca la sesión como
  /// activa para que el reloj arranque solo.
  Future<void> connect() async {
    await _apiService.updateSession(activeRackId: _selectedRackId, linked: true);
    await _linkClient.connect(_selectedRackId);
  }

  /// Botón "Detener": apaga la sesión compartida, así el reloj también
  /// deja de enviar datos.
  Future<void> disconnect() async {
    await _apiService.updateSession(linked: false);
    _linkClient.disconnect();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _linkClient.dispose();
    super.dispose();
  }
}
