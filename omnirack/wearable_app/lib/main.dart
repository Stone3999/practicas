import 'dart:async';

import 'package:flutter/material.dart';

import 'ble_server.dart';
import 'omnirack_colors.dart';
import 'rack_sensor_data.dart';
import 'sensor_simulator.dart';

void main() => runApp(const WearableApp());

// logica
// logica
// logica
// logica
// logica
class WearableApp extends StatefulWidget {
  const WearableApp({super.key});

  @override
  State<WearableApp> createState() => _WearableAppState();
}

class _WearableAppState extends State<WearableApp> {
  late final SensorSimulator _sim;
  late final BleServer _server;
  final List<StreamSubscription> _subs = [];

  RackSensorData? _data;
  String? _serverError;
  String? _config;

  @override
  void initState() {
    super.initState();
    _sim = SensorSimulator();
    _server = BleServer(_sim);
    
    _server.onConfigReceived = (config) {
      if (mounted) {
        setState(() {
          _config = config;
        });
      }
    };
    
    _subs.add(_sim.dataStream.listen((d) {
      if (mounted) {
        setState(() => _data = d);
      }
    }));

    // logica
    _sim.start();
    _server.startAdvertising().catchError((e) {
      if (mounted) {
        setState(() {
          _serverError = 'BLE Error: $e';
        });
      }
    });
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _server.stop();
    _sim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OmniRack Sensor',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black, // logica
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;
              final double w = size * 0.95; // logica
              
              final data = _data;
              final double temp = data?.temperature ?? 0.0;
              final bool isAlert = data?.isAlert ?? (temp > 35.0);
              final Color tempColor = temp > 35.0 ? OmniRackColors.red : Colors.grey.shade800;
              
              return Container(
                width: w,
                height: w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: w * 0.08, // logica
                  ),
                ),
                child: _config == null
                    ? Center(
                        child: Text(
                          'Esperando\nconfiguración...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600, 
                            fontSize: w * 0.08,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : (data == null ? const SizedBox.shrink() : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // logica
                          Icon(
                            isAlert ? Icons.warning_rounded : Icons.check_circle_rounded,
                            color: isAlert ? OmniRackColors.red : OmniRackColors.green,
                            size: w * 0.18,
                          ),
                          SizedBox(height: w * 0.02),
                          
                          // logica
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                temp.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: w * 0.35,
                                  fontWeight: FontWeight.bold,
                                  color: tempColor,
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                '°C',
                                style: TextStyle(
                                  fontSize: w * 0.12,
                                  fontWeight: FontWeight.bold,
                                  color: tempColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: w * 0.04),
                          
                          // logica
                          Text(
                            _config ?? 'Rack 1',
                            style: TextStyle(
                              fontSize: w * 0.08,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )),
              );
            },
          ),
        ),
      ),
    );
  }
}
