import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_icon.dart';

class DetailScreen extends StatefulWidget {
  final String city;

  const DetailScreen({super.key, required this.city});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<WeatherProvider>().fetchWeather(widget.city);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape = width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.city} - Detalle'),
        centerTitle: true,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, wp, _) {
          if (wp.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (wp.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(wp.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => wp.fetchWeather(widget.city),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final w = wp.weather;
          if (w == null) {
            return const Center(child: Text('Sin datos'));
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WeatherIcon(condition: w.condition, size: 80),
                  const SizedBox(height: 8),
                  Text(
                    '${w.temperature}°C',
                    style: const TextStyle(
                        fontSize: 48,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(w.description,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isLandscape
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _stats(w),
                            )
                          : Column(
                              children: _stats(w),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _stats(Weather w) {
    return [
      _statItem(Icons.water_drop, 'Humedad', '${w.humidity}%'),
      const SizedBox(height: 12),
      _statItem(Icons.air, 'Viento', '${w.windSpeed} m/s'),
      const SizedBox(height: 12),
      _statItem(Icons.thermostat, 'Sensación', '${w.temperature}°C'),
    ];
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
