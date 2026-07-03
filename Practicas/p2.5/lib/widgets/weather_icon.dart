import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;

  const WeatherIcon({
    super.key,
    required this.condition,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIcon(),
      size: size,
      color: Colors.blue,
    );
  }

  IconData _getIcon() {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.sunny;
      case 'rainy':
        return Icons.water_drop;
      case 'cloudy':
        return Icons.cloud;
      case 'stormy':
        return Icons.thunderstorm;
      case 'snowy':
        return Icons.ac_unit;
      default:
        return Icons.cloud;
    }
  }
}
