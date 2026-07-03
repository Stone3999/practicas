import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<WeatherProvider>().fetchWeather('Queretaro');
      }
    });
  }

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
      appBar: AppBar(
        title: const Text('Climate App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Buscar ciudades',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBLESection(),
          Divider(),
          _buildWeatherSection(),
        ],
      ),
    );
  }

  Widget _buildBLESection() {
    return Consumer<WeatherProvider>(
      builder: (context, wp, _) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bluetooth, size: 20),
                  const SizedBox(width: 8),
                  const Text('Dispositivo BLE',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (wp.isConnected) ...[
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    Text(wp.bleDeviceName ?? 'Conectado'),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.bluetooth_disabled, size: 18),
                      onPressed: () => wp.disconnectDevice(),
                      tooltip: 'Desconectar',
                    ),
                  ] else ...[
                    if (wp.isScanning)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    IconButton(
                      icon: Icon(
                        wp.isScanning ? Icons.stop : Icons.bluetooth_searching,
                        size: 20,
                      ),
                      onPressed:
                          () => wp.isScanning ? wp.stopScan() : wp.startScan(),
                      tooltip: wp.isScanning ? 'Detener' : 'Escanear',
                    ),
                  ],
                ],
              ),
              if (wp.isScanning && wp.scanResults.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: wp.scanResults.length,
                    itemBuilder: (context, i) {
                      final r = wp.scanResults[i];
                      final name = r.advertisementData.advName;
                      if (name.isEmpty) return const SizedBox.shrink();
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.bluetooth, size: 18),
                        title: Text(name, style: const TextStyle(fontSize: 14)),
subtitle: Text(r.device.remoteId.str,
    style: const TextStyle(fontSize: 11)),
trailing: const Icon(Icons.link, size: 16),
onTap: () => wp.connectToDevice(
    r.device.remoteId.str, name),
                      );
                    },
                  ),
                ),
              if (wp.bleTemperature != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Temp BLE: ${wp.bleTemperature}C  |  Ciudad: ${wp.bleCity ?? "---"}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherSection() {
    return Expanded(
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => wp.fetchWeather(
                        wp.bleCity ?? 'Queretaro'),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (wp.weather == null) {
            return const Center(child: Text('Ingresa una ciudad'));
          }
          final w = wp.weather!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(w.city,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('${w.temperature}°C',
                    style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
                Text(w.description,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('Humedad', '${w.humidity}%'),
                    _stat('Viento', '${w.windSpeed} m/s'),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Buscar otra ciudad...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      );
}
