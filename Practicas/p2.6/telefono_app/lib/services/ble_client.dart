import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../ble_constants.dart';
import '../models/activity_data.dart';

class BleClient {
  BluetoothDevice? _device;
  final List<StreamSubscription> _subs = [];
  Timer? _simTimer;

  final _dataCtrl = StreamController<ActivityData>.broadcast();
  Stream<ActivityData> get dataStream => _dataCtrl.stream;

  bool _connected = false;
  bool get isConnected => _connected;

  ActivityData _current = ActivityData(
    steps: 0,
    heartRate: 0,
    calories: 0,
    status: 'sin datos',
    timestamp: DateTime.now(),
  );

  Future<void> scanAndConnect() async {
    print('[BleClient] Iniciando escaneo BLE...');
    bool found = false;

    try {
      final completer = Completer<BluetoothDevice>();

      final scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          final uuids = r.advertisementData.serviceUuids
              .map((u) => u.toString().toLowerCase());
          if (uuids.contains(BleConstants.serviceUUID.toLowerCase())) {
            if (!completer.isCompleted) {
              print('[BleClient] Wearable encontrado: ${r.device.platformName}');
              completer.complete(r.device);
            }
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      try {
        _device = await completer.future.timeout(
          const Duration(seconds: 6),
          onTimeout: () => throw Exception('no encontrado'),
        );
        found = true;
      } finally {
        await FlutterBluePlus.stopScan();
        scanSub.cancel();
      }
    } catch (_) {
      found = false;
    }

    if (found) {
      await _connect();
    } else {
      print('[BleClient] Wearable no encontrado — iniciando simulación BLE');
      _startSimulation();
    }
  }

  Future<void> _connect() async {
    await _device!.connect();
    _connected = true;
    print('[BleClient] Conectado a ${_device!.platformName}');

    _device!.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _connected = false;
        print('[BleClient] Desconectado');
      }
    });

    await _discoverAndSubscribe();
  }

  Future<void> _discoverAndSubscribe() async {
    final services = await _device!.discoverServices();
    for (final svc in services) {
      if (svc.uuid.toString().toLowerCase() !=
          BleConstants.serviceUUID.toLowerCase()) continue;

      print('[BleClient] Servicio de actividad encontrado');
      for (final char in svc.characteristics) {
        final uuid = char.uuid.toString().toLowerCase();

        if (char.properties.notify) {
          await char.setNotifyValue(true);
          print('[BleClient] NOTIFY activado: $uuid');
        }

        final sub = char.lastValueStream.listen((bytes) {
          _handleValue(uuid, bytes);
        });
        _subs.add(sub);
      }
    }
  }

  void _handleValue(String uuid, List<int> bytes) {
    if (bytes.isEmpty) return;
    try {
      if (uuid == BleConstants.stepsUUID.toLowerCase()) {
        final bd = ByteData.sublistView(Uint8List.fromList(bytes));
        _current = _current.copyWith(steps: bd.getInt32(0, Endian.little));
      } else if (uuid == BleConstants.heartRateUUID.toLowerCase()) {
        _current = _current.copyWith(heartRate: bytes[0]);
      } else if (uuid == BleConstants.caloriesUUID.toLowerCase()) {
        final bd = ByteData.sublistView(Uint8List.fromList(bytes));
        _current = _current.copyWith(calories: bd.getInt16(0, Endian.little));
      } else if (uuid == BleConstants.statusUUID.toLowerCase()) {
        _current = _current.copyWith(status: utf8.decode(bytes));
      }
      _dataCtrl.add(_current);
    } catch (e) {
      print('[BleClient] Error parseando $uuid: $e');
    }
  }

  // Simula los datos que vendrian del reloj via BLE NOTIFY
  void _startSimulation() {
    _connected = true;
    final rng = Random();
    int steps = 0;
    int calories = 0;
    final statuses = ['reposo', 'caminando', 'corriendo'];
    int statusIdx = 0;
    int tick = 0;

    _simTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      tick++;
      // Cambiar actividad cada 20 segundos
      if (tick % 20 == 0) statusIdx = (statusIdx + 1) % statuses.length;
      final status = statuses[statusIdx];

      int bpm;
      int stepDelta;
      int calDelta;
      switch (status) {
        case 'corriendo':
          bpm = 130 + rng.nextInt(30);
          stepDelta = 3 + rng.nextInt(2);
          calDelta = 2;
          break;
        case 'caminando':
          bpm = 90 + rng.nextInt(20);
          stepDelta = 1 + rng.nextInt(2);
          calDelta = 1;
          break;
        default:
          bpm = 65 + rng.nextInt(15);
          stepDelta = 0;
          calDelta = 0;
      }

      steps += stepDelta;
      calories += calDelta;

      _current = ActivityData(
        steps: steps,
        heartRate: bpm,
        calories: calories,
        status: status,
        timestamp: DateTime.now(),
      );
      _dataCtrl.add(_current);
    });
  }

  Future<void> disconnect() async {
    _simTimer?.cancel();
    _simTimer = null;
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    await _device?.disconnect();
    _connected = false;
  }

  void dispose() {
    _simTimer?.cancel();
    _dataCtrl.close();
  }
}
