import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_icon.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
      context.read<WeatherProvider>().fetchWeather(city);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Ciudades')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa una ciudad...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WeatherProvider>(
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
                      ],
                    ),
                  );
                }
                if (wp.weather == null) {
                  return const Center(child: Text('Busca una ciudad'));
                }
                final w = wp.weather!;
                return ListTile(
                  leading: WeatherIcon(condition: w.condition, size: 40),
                  title: Text(w.city),
                  subtitle: Text('${w.temperature}°C - ${w.description}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(city: w.city),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
