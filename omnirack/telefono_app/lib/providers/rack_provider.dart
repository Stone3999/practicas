import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/rack.dart';
import '../models/rack_sensor_data.dart';
import '../services/api_service.dart';
import '../services/ble_client.dart';

class RackProvider with ChangeNotifier {
  final BleClient _bleClient = BleClient();
  final ApiService _apiService = ApiService();

  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BleConnectionState get connectionState => _connectionState;

  RackSensorData? _currentData;
  RackSensorData? get currentData => _currentData;

  List<Rack> _racks = [];
  List<Rack> get racks => _racks;

  String _selectedRackId = 'RACK-01';
  String get selectedRackId => _selectedRackId;

  List<dynamic> _alerts = [];
  List<dynamic> get alerts => _alerts;

  RackProvider() {
    _selectedRackId = dotenv.env['DEFAULT_RACK_ID'] ?? 'RACK-01';
    _init();
  }

  void _init() {
    _bleClient.stateStream.listen((state) {
      _connectionState = state;
      notifyListeners();
    });

    _bleClient.dataStream.listen((data) {
      _currentData = data;
      _apiService.sendRackData(_selectedRackId, data);
      notifyListeners();
    });

    _bleClient.start();
    fetchRacks();
  }

  Future<void> fetchRacks() async {
    _racks = await _apiService.getRacks();
    notifyListeners();
  }

  void selectRack(String id) {
    _selectedRackId = id;
    notifyListeners();
  }
  
  Future<void> fetchAlerts() async {
    _alerts = await _apiService.getAlerts();
    notifyListeners();
  }

  Future<bool> writeWearableConfig(String dataCenter, String rack) async {
    return await _bleClient.writeWearableConfig(dataCenter, rack);
  }

  @override
  void dispose() {
    _bleClient.dispose();
    super.dispose();
  }
}
