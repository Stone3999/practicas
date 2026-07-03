import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  static const String serviceUuid = "0000fff0-0000-1000-8000-00805f9b34fb";
  static const String tempCharUuid = "0000fff2-0000-1000-8000-00805f9b34fb";
  static const String cityCharUuid = "0000fff1-0000-1000-8000-00805f9b34fb";

  BluetoothDevice? _connectedDevice;
  List<BluetoothService>? _discoveredServices;
  StreamSubscription? _scanSubscription;
  String? _lastDeviceId;

  bool get isConnected => _connectedDevice?.isConnected ?? false;
  String? get lastDeviceId => _lastDeviceId;
  Stream<BluetoothConnectionState>? get deviceState => _connectedDevice?.connectionState;

  Stream<List<ScanResult>> scanForDevices() {
    _scanSubscription?.cancel();
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      androidUsesFineLocation: false,
      androidCheckLocationServices: false,
    );
    return FlutterBluePlus.scanResults;
  }

  void stopScan() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
  }

  Future<bool> connect(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(license: License.nonprofit);
      _connectedDevice = device;
      _lastDeviceId = deviceId;
      _discoveredServices = await device.discoverServices();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> reconnect() async {
    if (_lastDeviceId == null) return false;
    return await connect(_lastDeviceId!);
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _discoveredServices = null;
  }

  String getServicesInfo() {
    if (_discoveredServices == null) return 'null';
    if (_discoveredServices!.isEmpty) return 'vacio';
    final sb = StringBuffer();
    for (final s in _discoveredServices!) {
      final serviceUuid = _shortUuid(s.uuid.toString());
      sb.write('Servicio $serviceUuid (${s.uuid}): ');
      for (final c in s.characteristics) {
        final charUuid = _shortUuid(c.uuid.toString());
        sb.write('$charUuid (${c.uuid})[${c.properties.read ? 'R' : ''}${c.properties.write ? 'W' : ''}${c.properties.notify ? 'N' : ''}] ');
      }
      sb.write(' | ');
    }
    return sb.toString();
  }

  bool _matchesUuid(String actualUuid, String targetUuid) {
    final normalizedActual = actualUuid.toLowerCase();
    final normalizedTarget = targetUuid.toLowerCase();
    if (normalizedActual == normalizedTarget) return true;
    return _shortUuid(normalizedActual) == _shortUuid(normalizedTarget);
  }

  String _shortUuid(String uuid) {
    final normalized = uuid.toLowerCase();
    if (normalized.length >= 8 && normalized.contains('-')) {
      return normalized.substring(4, 8);
    }
    if (normalized.length >= 4) {
      return normalized.substring(normalized.length - 4);
    }
    return normalized;
  }

  Future<String?> readTemperature() async {
    try {
      final value = await _readCharacteristic(tempCharUuid);
      if (value == null) return null;
      final tempStr = _decodeString(value).trim();
      final temp = double.tryParse(tempStr);
      if (temp == null || temp < -60 || temp > 60) return null;
      return tempStr;
    } catch (_) {
      return null;
    }
  }

  Future<String?> readCity() async {
    try {
      final value = await _readCharacteristic(cityCharUuid);
      if (value == null) return null;
      final city = _decodeString(value).trim();
      if (city.isEmpty || city.length > 50) return null;
      return city;
    } catch (_) {
      return null;
    }
  }

  String _decodeString(List<int> value) {
    final filtered = value.where((byte) => byte != 0).toList();
    return utf8.decode(filtered, allowMalformed: true);
  }

  Future<List<int>?> _readCharacteristic(String charUuid) async {
    if (_connectedDevice == null || _discoveredServices == null) return null;
    final targetUuid = charUuid.toLowerCase();
    for (final service in _discoveredServices!) {
      if (_matchesUuid(service.uuid.toString(), serviceUuid)) {
        for (final characteristic in service.characteristics) {
          if (_matchesUuid(characteristic.uuid.toString(), targetUuid)) {
            return await characteristic.read();
          }
        }
      }
    }

    // Fallback: search all services if the expected service UUID is not exactly matched.
    for (final service in _discoveredServices!) {
      for (final characteristic in service.characteristics) {
        if (_matchesUuid(characteristic.uuid.toString(), targetUuid)) {
          return await characteristic.read();
        }
      }
    }
    return null;
  }
}
