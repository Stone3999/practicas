// logica
// logica
// logica
// logica
// logica
// logica
// logica
// logica
class RackSensorData {
  final double temperature;
  final int humidity;
  final double power;
  final String door;
  final int alert;
  final DateTime timestamp;

  const RackSensorData({
    required this.temperature,
    required this.humidity,
    required this.power,
    required this.door,
    required this.alert,
    required this.timestamp,
  });

  bool get isAlert => alert == 1;

  bool get isDoorOpen => door == 'OPEN';

  RackSensorData copyWith({
    double? temperature,
    int? humidity,
    double? power,
    String? door,
    int? alert,
    DateTime? timestamp,
  }) {
    return RackSensorData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      power: power ?? this.power,
      door: door ?? this.door,
      alert: alert ?? this.alert,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'RackSensorData(temp: $temperature C, hum: $humidity %, '
        'power: $power kW, door: $door, alert: $alert, at: $timestamp)';
  }
}
