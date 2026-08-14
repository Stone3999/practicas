import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/rack_sensor_data.dart';

enum LinkState { disconnected, connecting, connected, error }

// logica
// logica
// logica
/// Vincula el celular con un rack consultando el backend OMNIRACK por IP
/// local (el mismo backend al que el reloj envia sus lecturas). Sustituye
/// al enlace BLE reloj->celular: al no haber intermediario, el celular
/// y el reloj terminan mostrando exactamente el mismo dato.
class RackLinkClient {
  Timer? _pollTimer;
  String? _rackId;
  String? _lastTimestamp;

  final _dataController = StreamController<RackSensorData>.broadcast();
  final _stateController = StreamController<LinkState>.broadcast();

  Stream<RackSensorData> get dataStream => _dataController.stream;
  Stream<LinkState> get stateStream => _stateController.stream;

  LinkState _state = LinkState.disconnected;
  LinkState get state => _state;

  Future<void> connect(String rackId) async {
    _rackId = rackId;
    _lastTimestamp = null;
    _pollTimer?.cancel();
    _updateState(LinkState.connecting);
    await _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _poll());
  }

  void disconnect() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _updateState(LinkState.disconnected);
  }

  Future<void> _poll() async {
    final rackId = _rackId;
    if (rackId == null) return;
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.rack(rackId)))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final latest = body['latest'];
        if (latest != null) {
          final data = RackSensorData.fromJson(latest as Map<String, dynamic>);
          final ts = data.timestamp.toIso8601String();
          if (ts != _lastTimestamp) {
            _lastTimestamp = ts;
            _dataController.add(data);
          }
        }
        _updateState(LinkState.connected);
      } else {
        _updateState(LinkState.error);
      }
    } catch (_) {
      _updateState(LinkState.error);
    }
  }

  void _updateState(LinkState state) {
    _state = state;
    if (!_stateController.isClosed) _stateController.add(state);
  }

  void dispose() {
    _pollTimer?.cancel();
    _dataController.close();
    _stateController.close();
  }
}
