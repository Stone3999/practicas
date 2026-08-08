import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rack_provider.dart';

class RackDetailScreen extends StatelessWidget {
  const RackDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RackProvider>(context);
    final data = provider.currentData;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Gráficas (6 Racks)', style: TextStyle(color: Color(0xFF181818), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Temperatura por Rack',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // logica
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  final rackNum = index + 1;
                  double temp = 25.0 + (index * 1.5);
                  if (rackNum == 1 && data != null) {
                    temp = data.temperature;
                  } else if (rackNum == 3) {
                    temp = 36.5; // logica
                  }

                  // logica
                  final double heightRatio = (temp.clamp(0.0, 50.0)) / 50.0;
                  final color = temp >= 35 ? const Color(0xFFC81030) : const Color(0xFF40F000);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${temp.toStringAsFixed(1)}°',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: 150 * heightRatio,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('R$rackNum', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
            // logica
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.0,
                children: [
                  _buildStatCard(
                    'Promedio Temp',
                    '28.5 °C',
                    Icons.thermostat,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Humedad Global',
                    data != null ? '${data.humidity}%' : '55%',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Consumo Total',
                    '42.0 kW',
                    Icons.bolt,
                    Colors.amber,
                  ),
                  _buildStatCard(
                    'Estado Red',
                    provider.connectionState.name.toUpperCase(),
                    Icons.wifi,
                    provider.connectionState.name == 'connected' ? Colors.green : Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
