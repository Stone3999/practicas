import 'package:climate_app/providers/weather_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carga datos al abrir
    Provider.of<WeatherProvider>(context, listen: false).loadWeather('Santiago de Querétaro noob');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Climate')),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, _) {
          if (weatherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (weatherProvider.errorMessage != null) {
            return Center(child: Text('Error: ${weatherProvider.errorMessage}'));
          }

          if (weatherProvider.weather == null) {
            return const Center(child: Text('No data'));
          }

          final currentWeather = weatherProvider.weather!;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${currentWeather.temperature}${weatherProvider.temperatureUnit}',
                  style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                ),
                Text(currentWeather.city),
                Text('Humidity: ${currentWeather.humidity}%'),
                const SizedBox(height: 16), // Un pequeño espacio antes del botón viene bien
                ElevatedButton(
                  onPressed: () => weatherProvider.toggleTemperatureUnit(),
                  child: const Text('Cambiar unidad'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}