import 'dart:async';

import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'omnirack_colors.dart';
import 'rack_sensor_data.dart';
import 'sensor_simulator.dart';
import 'services/backend_client.dart';

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
  late final BackendClient _client;
  final List<StreamSubscription> _subs = [];
  Timer? _sessionTimer;

  RackSensorData? _data;
  LinkState _link = LinkState.disconnected;
  String _rackId = AppConfig.defaultRackId;

  @override
  void initState() {
    super.initState();
    _sim = SensorSimulator();
    _client = BackendClient(rackId: AppConfig.defaultRackId);

    _subs.add(_client.stateStream.listen((state) {
      if (mounted) setState(() => _link = state);
    }));

    // logica
    _subs.add(_sim.dataStream.listen((d) {
      if (mounted) setState(() => _data = d);
      _client.sendReading(d);
    }));

    // logica
    // logica
    _sessionTimer = Timer.periodic(const Duration(seconds: 2), (_) => _syncSession());
    _syncSession();
  }

  // logica
  // logica
  /// Sigue el estado compartido en el backend: si el celular apagó la
  /// sesión, este reloj se detiene; si el celular cambió de Data Center,
  /// este reloj empieza a enviar al nuevo rack.
  Future<void> _syncSession() async {
    final session = await _client.fetchSession();
    if (session == null) return;

    final remoteRackId = session['activeRackId'] as String?;
    final remoteLinked = session['linked'] as bool? ?? false;

    if (remoteRackId != null && remoteRackId != _rackId) {
      setState(() => _rackId = remoteRackId);
      _client.rackId = remoteRackId;
    }

    if (remoteLinked && !_sim.isRunning) {
      setState(() => _sim.start());
      _client.connect();
    } else if (!remoteLinked && _sim.isRunning) {
      setState(() => _sim.stop());
      _client.disconnect();
    }
  }

  // logica
  void _toggleConnect() {
    final willRun = !_sim.isRunning;
    setState(() {
      if (willRun) {
        _sim.start();
      } else {
        _sim.stop();
      }
    });

    if (willRun) {
      _client.connect();
    } else {
      _client.disconnect();
    }
    _client.pushSession(activeRackId: _rackId, linked: willRun);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _client.dispose();
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          mini: true,
          onPressed: _toggleConnect,
          backgroundColor:
              _sim.isRunning ? Colors.grey.shade800 : OmniRackColors.red,
          tooltip: _sim.isRunning ? 'Detener' : 'Conectar',
          child: Icon(_sim.isRunning ? Icons.link_off : Icons.link),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 32), // logica: deja hueco para el FAB
          child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;
              final double w = size * 0.8; // logica

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
                child: !_sim.isRunning
                    ? Center(
                        child: Text(
                          'Toca Conectar\npara vincular',
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
                          SizedBox(height: w * 0.03),

                          // logica
                          Text(
                            _rackId,
                            style: TextStyle(
                              fontSize: w * 0.08,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: w * 0.02),

                          // logica
                          Text(
                            _link == LinkState.connected
                                ? 'Enviando ●'
                                : (_link == LinkState.error
                                    ? 'Sin backend ⚠'
                                    : 'Conectando...'),
                            style: TextStyle(
                              fontSize: w * 0.05,
                              fontWeight: FontWeight.bold,
                              color: _link == LinkState.connected
                                  ? OmniRackColors.green
                                  : OmniRackColors.red,
                            ),
                          ),
                        ],
                      )),
              );
            },
          ),
          ),
        ),
      ),
    );
  }
}
