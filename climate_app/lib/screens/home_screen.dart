import 'package:climate_app/screens/search_screen.dart';
import 'package:climate_app/widgets/weather_icon.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;

    final info = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '29°C',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Querétaro',
          style: TextStyle(
            fontSize: 24,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Humedad: 65%  |  Viento: 12 km/h',
          style: TextStyle(
            fontSize: 24,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
          child: const Text('Buscar Ciudades'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('App de clima final (pruebas)'),
        centerTitle: true,
      ),
      body: Center(
        child: ancho > 600
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const WeatherIcon(estado: 'soleado'),
                  info,
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const WeatherIcon(estado: 'soleado'),
                    info,
                  ],
                ),
              ),
      ),
    );
  }
}