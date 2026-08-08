import 'dart:async';
import 'dart:math';

import 'rack_sensor_data.dart';

// logica
// logica
// logica
// logica
// logica
// logica
// logica
class SensorSimulator {
  final _random = Random();

  double _temperature = 24.5;
  int _humidity = 55;
  double _power = 6.0;
  String _door = 'CLOSED';
  int _doorOpenTicks = 0;

  final _dataCtrl = StreamController<RackSensorData>.broadcast();

  Stream<RackSensorData> get dataStream => _dataCtrl.stream;

  Timer? _timer;

  RackSensorData _buildData() {
    return RackSensorData(
      temperature: _temperature,
      humidity: _humidity,
      power: _power,
      door: _door,
      alert: _isAlert ? 1 : 0,
      timestamp: DateTime.now(),
    );
  }

  bool get _isAlert =>
      _temperature >= 35.0 ||
      _humidity <= 10 || _humidity >= 85 ||
      _power >= 9.5 ||
      _door == 'OPEN';

  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _update());
  }

  void _update() {
    // logica
    _temperature = (_temperature + (_random.nextInt(3) - 1).toDouble())
        .clamp(18.0, 38.0);

    // logica
    _humidity = (_humidity + _random.nextInt(7) - 3).clamp(30, 80);

    // logica
    _power = (_power + (_random.nextInt(11) - 5) * 0.2).clamp(2.0, 12.0);

    // logica
    if (_door == 'CLOSED') {
      if (_random.nextInt(100) == 0) {
        _door = 'OPEN';
        _doorOpenTicks = _random.nextInt(3) + 2;
      }
    } else {
      _doorOpenTicks--;
      if (_doorOpenTicks <= 0) _door = 'CLOSED';
    }

    if (!_dataCtrl.isClosed) _dataCtrl.add(_buildData());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _dataCtrl.close();
  }
}
