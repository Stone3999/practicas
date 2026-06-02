import 'package:climate_app/widgets/temperature_card.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String city;

  const DetailScreen({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$city - 5 Días')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  TemperatureCard(dia: 'Lun', clima: '24°C'),
                  TemperatureCard(dia: 'Mar', clima: '26°C'),
                  TemperatureCard(dia: 'Mié', clima: '20°C'),
                  TemperatureCard(dia: 'Jue', clima: '25°C'),
                  TemperatureCard(dia: 'Vie', clima: '28°C'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}