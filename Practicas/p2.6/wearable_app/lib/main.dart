import 'dart:async';
import 'package:flutter/material.dart';
import 'sensor_simulator.dart';
import 'ble_server.dart';

void main() => runApp(const WearableApp());

class WearableApp extends StatefulWidget {
  const WearableApp({super.key});

  @override
  State<WearableApp> createState() => _WearableAppState();
}

class _WearableAppState extends State<WearableApp> {
  late final SensorSimulator _sim;
  late final BleServer _server;
  final List<StreamSubscription> _subs = [];

  int _steps = 0;
  int _heartRate = 72;
  int _calories = 0;
  String _status = 'reposo';
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _sim = SensorSimulator();
    _server = BleServer(_sim);
    _subscribeStreams();
  }

  void _subscribeStreams() {
    _subs.add(_sim.stepsStream.listen((v) => setState(() => _steps = v)));
    _subs.add(_sim.heartRateStream.listen((v) => setState(() => _heartRate = v)));
    _subs.add(_sim.caloriesStream.listen((v) => setState(() => _calories = v)));
    _subs.add(_sim.statusStream.listen((v) => setState(() => _status = v)));
  }

  void _toggleActivity() {
    setState(() => _active = !_active);
    if (_active) {
      _sim.start();
      _server.startAdvertising();
    } else {
      _server.stop();
    }
  }

  Color get _statusColor {
    switch (_status) {
      case 'corriendo': return Colors.redAccent;
      case 'caminando': return Colors.cyanAccent;
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    for (final s in _subs) s.cancel();
    _server.stop();
    _sim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            final bpmColor = _heartRate > 120 ? Colors.redAccent : Colors.white;

            return Column(
              children: [
                // Chip de estado arriba
                Padding(
                  padding: EdgeInsets.only(top: h * 0.06),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.06,
                      vertical: h * 0.012,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(w * 0.1),
                      border: Border.all(color: _statusColor, width: 1.2),
                    ),
                    child: Text(
                      _status.toUpperCase(),
                      style: TextStyle(
                        fontSize: w * 0.038,
                        color: _statusColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // BPM en el centro
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, color: bpmColor, size: w * 0.08),
                    SizedBox(height: h * 0.01),
                    Text(
                      '$_heartRate',
                      style: TextStyle(
                        fontSize: w * 0.22,
                        fontWeight: FontWeight.bold,
                        color: bpmColor,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'bpm',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: w * 0.05,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Pasos y calorías
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _stat(Icons.directions_walk, '$_steps', 'pasos',
                        Colors.greenAccent, w),
                    SizedBox(width: w * 0.1),
                    _stat(Icons.local_fire_department, '$_calories', 'kcal',
                        Colors.orangeAccent, w),
                  ],
                ),

                SizedBox(height: h * 0.02),

                // Botón y estado de envío al fondo
                if (_active)
                  Padding(
                    padding: EdgeInsets.only(bottom: h * 0.01),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: w * 0.015),
                        Text(
                          'Enviando datos',
                          style: TextStyle(
                            fontSize: w * 0.032,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: w * 0.38,
                  height: h * 0.1,
                  child: ElevatedButton(
                    onPressed: _toggleActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _active ? Colors.red[800] : Colors.green[700],
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(w * 0.08),
                      ),
                    ),
                    child: Text(
                      _active ? 'Detener' : 'Iniciar',
                      style: TextStyle(
                        fontSize: w * 0.042,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.04),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, String unit, Color color, double w) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: w * 0.06),
        SizedBox(height: w * 0.01),
        Text(
          value,
          style: TextStyle(
            fontSize: w * 0.055,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: w * 0.033,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
