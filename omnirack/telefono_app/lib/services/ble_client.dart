import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../ble_constants.dart';
import '../models/rack_sensor_data.dart';

enum BleConnectionState { disconnected, scanning, connected, simulating, error }

class BleClient {
  BluetoothDevice? _device;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  
  final _dataController = StreamController<RackSensorData>.broadcast();
  final _stateController = StreamController<BleConnectionState>.broadcast();
  
  Stream<RackSensorData> get dataStream => _dataController.stream;
  Stream<BleConnectionState> get stateStream => _stateController.stream;

  Timer? _simulationTimer;
  Timer? _scanTimer;
  
  // logica
  double _temp = 25.0;
  int _hum = 50;
  double _pow = 5.0;
  String _door = 'CLOSED';

  Future<void> start() async {
    _updateState(BleConnectionState.scanning);
    
    // logica
    if (await FlutterBluePlus.isSupported == false) {
      _startSimulation();
      return;
    }

    try {
      await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;
      
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.advName == BleConstants.deviceName || 
              r.advertisementData.serviceUuids.contains(Guid(BleConstants.serviceUUID))) {
            await _connectToDevice(r.device);
            break;
          }
        }
      });

      await FlutterBluePlus.startScan(
        withServices: [Guid(BleConstants.serviceUUID)],
        timeout: const Duration(seconds: 10),
      );

      _scanTimer = Timer(const Duration(seconds: 10), () {
        if (_device == null) {
          FlutterBluePlus.stopScan();
          _startSimulation();
        }
      });
    } catch (e) {
      _startSimulation();
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    FlutterBluePlus.stopScan();
    _scanTimer?.cancel();
    _device = device;
    
    _connectionSubscription = _device!.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.connected) {
        _updateState(BleConnectionState.connected);
        await _setupServices();
      } else if (state == BluetoothConnectionState.disconnected) {
        _updateState(BleConnectionState.disconnected);
        _device = null;
        // logica
        _startSimulation();
      }
    });

    try {
      await _device!.connect(timeout: const Duration(seconds: 5));
    } catch (e) {
      _updateState(BleConnectionState.error);
      _startSimulation();
    }
  }

  Future<void> _setupServices() async {
    if (_device == null) return;
    try {
      List<BluetoothService> services = await _device!.discoverServices();
      BluetoothService? sensorService;
      for (var service in services) {
        if (service.uuid == Guid(BleConstants.serviceUUID)) {
          sensorService = service;
          break;
        }
      }

      if (sensorService == null) throw Exception("Service not found");

      for (var characteristic in sensorService.characteristics) {
        await characteristic.setNotifyValue(true);
        characteristic.onValueReceived.listen((value) {
          _handleBleData(characteristic.uuid.toString(), value);
        });
      }
    } catch (e) {
      _updateState(BleConnectionState.error);
    }
  }

  void _handleBleData(String uuid, List<int> bytes) {
    if (bytes.isEmpty) return;

    if (uuid == Guid(BleConstants.temperatureUUID).toString()) {
      try {
        final str = utf8.decode(bytes);
        if (str.contains('|')) {
          final parts = str.split('|');
          for (var p in parts) {
            final kv = p.split(':');
            if (kv.length == 2) {
              if (kv[0] == 'temp') _temp = double.parse(kv[1]);
              if (kv[0] == 'hum') _hum = int.parse(kv[1]);
              if (kv[0] == 'pwr') _pow = double.parse(kv[1]) / 100.0;
            }
          }
        } else {
          _temp = ByteData.sublistView(Uint8List.fromList(bytes)).getFloat32(0, Endian.little);
        }
      } catch (e) {
        try {
          _temp = ByteData.sublistView(Uint8List.fromList(bytes)).getFloat32(0, Endian.little);
        } catch (_) {}
      }
    } else if (uuid == Guid(BleConstants.humidityUUID).toString()) {
      _hum = bytes[0];
    } else if (uuid == Guid(BleConstants.powerUUID).toString()) {
      _pow = ByteData.sublistView(Uint8List.fromList(bytes)).getFloat32(0, Endian.little);
    } else if (uuid == Guid(BleConstants.doorUUID).toString()) {
      _door = utf8.decode(bytes);
    } else if (uuid == Guid(BleConstants.alertUUID).toString()) {
      int alert = bytes[0];
      _emitData(alert: alert);
      return; // logica
    }
    _emitData();
  }

  void _startSimulation() {
    _updateState(BleConnectionState.simulating);
    _simulationTimer?.cancel();
    final random = Random();

    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _temp += (random.nextDouble() - 0.5);
      if (_temp < 18) _temp = 18;
      if (_temp > 38) _temp = 38;

      _hum += random.nextInt(3) - 1;
      if (_hum < 30) _hum = 30;
      if (_hum > 80) _hum = 80;

      _pow += (random.nextDouble() - 0.5);
      if (_pow < 2) _pow = 2;
      if (_pow > 12) _pow = 12;

      if (random.nextDouble() < 0.05) {
        _door = _door == 'CLOSED' ? 'OPEN' : 'CLOSED';
      }

      int alert = 0;
      if (_temp >= 35 || _door == 'OPEN') alert = 1;

      _emitData(alert: alert);
    });
  }

  void _emitData({int alert = 0}) {
    _dataController.add(RackSensorData(
      temperature: _temp,
      humidity: _hum,
      power: _pow,
      door: _door,
      alert: alert,
      timestamp: DateTime.now(),
    ));
  }

  void _updateState(BleConnectionState state) {
    _stateController.add(state);
  }

  Future<bool> writeWearableConfig(String dataCenter, String rack) async {
    if (_device == null) return false;
    try {
      List<BluetoothService> services = await _device!.discoverServices();
      for (var service in services) {
        if (service.uuid == Guid(BleConstants.serviceUUID)) {
          for (var char in service.characteristics) {
            if (char.uuid == Guid(BleConstants.wearableConfigUUID)) {
              final data = utf8.encode('$dataCenter:$rack');
              await char.write(data, withoutResponse: false);
              return true;
            }
          }
        }
      }
    } catch (e) {
      print('Error writing config: $e');
    }
    return false;
  }

  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _simulationTimer?.cancel();
    _scanTimer?.cancel();
    _device?.disconnect();
    _dataController.close();
    _stateController.close();
  }
}
