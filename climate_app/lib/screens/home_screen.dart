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

          return Column(
            children: [
              // Estado de la conexión (Muestra "Sin conexion BLE" o el estado actual)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  weatherProvider.bleStatusMessage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: weatherProvider.isConnected ? Colors.green : Colors.red
                  ),
                ),
              ),
              
              if (weatherProvider.isConnecting)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),

              // Sección de Clima
              Expanded(
                flex: 2,
                child: Center(
                  child: weatherProvider.weather == null
                      ? const Text('Sin conexion BLE', style: TextStyle(fontSize: 20, color: Colors.red))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${weatherProvider.weather!.temperature}${weatherProvider.temperatureUnit}',
                              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                            ),
                            Text(weatherProvider.weather!.city),
                            Text('Humidity: ${weatherProvider.weather!.humidity}%'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => weatherProvider.toggleTemperatureUnit(),
                              child: const Text('Cambiar unidad'),
                            ),
                          ],
                        ),
                ),
              ),

              const Divider(),

              // Sección BLE
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Si está conectado, muestra botón de desconectar. Si no, muestra el de buscar.
                    weatherProvider.isConnected
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => weatherProvider.disconnectDevice(),
                            child: const Text('Desconectar Wearable', style: TextStyle(color: Colors.white)),
                          )
                        : ElevatedButton(
                            onPressed: weatherProvider.isScanning ? null : () => weatherProvider.startScanning(),
                            child: const Text('Buscar dispositivos BLE'),
                          ),
                          
                    if (weatherProvider.isScanning)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      
                    // Mostrar la lista solo si no está conectado a un dispositivo
                    if (!weatherProvider.isConnected)
                      Expanded(
                        child: ListView.builder(
                          itemCount: weatherProvider.scanResults.length,
                          itemBuilder: (context, index) {
                            final result = weatherProvider.scanResults[index];
                            final deviceName = result.device.platformName.isEmpty
                                ? 'Dispositivo Desconocido'
                                : result.device.platformName;

                            return ListTile(
                              title: Text(deviceName),
                              subtitle: Text(result.device.remoteId.toString()),
                              trailing: ElevatedButton(
                                onPressed: weatherProvider.isConnecting
                                    ? null
                                    : () => weatherProvider.connectToDevice(result.device.remoteId.toString()),
                                child: const Text('Conectar'),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}