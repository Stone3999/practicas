import 'package:flutter/material.dart';

class TemperatureCard extends StatelessWidget {
  final String dia;
  final String clima;

  const TemperatureCard({Key? key, required this.dia, required this.clima}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(dia, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(clima),
          ],
        ),
      ),
    );
  }
}