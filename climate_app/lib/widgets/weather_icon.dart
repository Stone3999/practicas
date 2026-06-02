import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String estado;

  const WeatherIcon({Key? key, required this.estado}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      estado == 'soleado' ? Icons.sunny : Icons.cloud,
      size: 120,
      color: estado == 'soleado' ? Colors.blue : Colors.grey,
    );
  }
}