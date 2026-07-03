import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../services/ble_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final BLEService _bleService = BLEService();

  Weather? _weather;
  bool _isLoading = false;
  String? _error;

  // BLE state
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  String? _bleTemperature;
  String? _bleCity;
  String? _bleDeviceName;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;
  bool get isConnected => _bleService.isConnected;
  String? get bleTemperature => _bleTemperature;
  String? get bleCity => _bleCity;
  String? get bleDeviceName => _bleDeviceName;

  StreamSubscription? _scanSub;

  void startScan() {
    _scanResults = [];
    _isScanning = true;
    notifyListeners();

    _scanSub?.cancel();
    final stream = _bleService.scanForDevices();
    _scanSub = stream.listen((results) {
      _scanResults = results;
      notifyListeners();
    }, onDone: () {
      _isScanning = false;
      notifyListeners();
    });
  }

  void stopScan() {
    _scanSub?.cancel();
    _bleService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<bool> connectToDevice(String deviceId, String deviceName) async {
    final ok = await _bleService.connect(deviceId);
    if (ok) {
      _bleDeviceName = deviceName;
      notifyListeners();
      await _readBLEData();
    }
    return ok;
  }

  Future<void> disconnectDevice() async {
    await _bleService.disconnect();
    _bleDeviceName = null;
    _bleTemperature = null;
    _bleCity = null;
    notifyListeners();
  }

  Future<void> _readBLEData() async {
    final temp = await _bleService.readTemperature();
    final city = await _bleService.readCity();
    _bleTemperature = temp;
    _bleCity = city;
    notifyListeners();

    if (city != null && city.isNotEmpty) {
      await fetchWeather(city);
    }
  }

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _weatherService.getWeather(city);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _bleService.disconnect();
    super.dispose();
  }
}
