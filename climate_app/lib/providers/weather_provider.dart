import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/weather_model.dart';
import '../services/ble_service.dart';

class WeatherProvider extends ChangeNotifier {
  final BLEService _bleService = BLEService();

  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  int _tempUnit = 0; 

  bool _isScanning = false;
  bool _isConnecting = false;
  String _bleStatusMessage = "Sin conexion BLE";
  List<ScanResult> _scanResults = [];

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get temperatureUnit => _tempUnit == 0 ? '°C' : '°F';

  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  String get bleStatusMessage => _bleStatusMessage;
  List<ScanResult> get scanResults => _scanResults;
  bool get isConnected => _bleService.isConnected;

  Future<void> loadWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _weather = Weather(
        city: city,
        temperature: 24,
        condition: 'cloudy',
        humidity: 65,
      );
    } catch (e) {
      _errorMessage = 'Error loading weather: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTemperatureUnit() {
    _tempUnit = _tempUnit == 0 ? 1 : 0;
    notifyListeners();
  }

  void updateTemperature(int newTemp) {
    if (_weather != null) {
      _weather = Weather(
        city: _weather!.city,
        temperature: newTemp,
        condition: _weather!.condition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }

  // --- MÉTODOS DEL PASO 10 ---

  void startScanning() {
    _isScanning = true;
    _scanResults = [];
    _bleStatusMessage = "Buscando dispositivos...";
    notifyListeners();

    _bleService.scanForDevices().listen((results) {
      _scanResults = results;
      notifyListeners();
    }, onDone: () {
      _isScanning = false;
      notifyListeners();
    });
  }

  void stopScanning() {
    _bleService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(String deviceId) async {
    _isConnecting = true;
    _bleStatusMessage = "Conectando al wearable...";
    notifyListeners();

    final success = await _bleService.connect(deviceId);

    if (success) {
      _bleStatusMessage = "Conectado. Leyendo datos...";
      notifyListeners();

      final rawTemp = await _bleService.readTemperature();
      final rawCity = await _bleService.readCity();

      if (rawTemp != null && rawCity != null) {
        final parsedTemp = double.tryParse(rawTemp)?.round() ?? 25;

        _weather = Weather(
          city: rawCity,
          temperature: parsedTemp,
          condition: 'sunny', 
          humidity: 50,
        );
        _bleStatusMessage = "Datos sincronizados con éxito";
      } else {
        _bleStatusMessage = "Conectado, pero fallo la lectura de datos";
      }
    } else {
      _bleStatusMessage = "Error al conectar";
    }

    _isConnecting = false;
    notifyListeners();
  }

  Future<void> disconnectDevice() async {
    await _bleService.disconnect();
    _weather = null;
    _bleStatusMessage = "Sin conexion BLE";
    notifyListeners();
  }
}