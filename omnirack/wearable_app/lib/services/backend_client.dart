import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../rack_sensor_data.dart';

enum LinkState { disconnected, connecting, connected, error }

// logica
// logica
// logica
/// Envia las lecturas del sensor directamente al backend OMNIRACK por la IP
/// local (el mismo backend que ya usa el telefono), reemplazando el enlace
/// BLE reloj->celular. Asi el reloj, el celular y la TV quedan sincronizados
/// contra una unica fuente de datos real.
class BackendClient {
  String rackId;

  BackendClient({this.rackId = AppConfig.defaultRackId});

  final _stateCtrl = StreamController<LinkState>.broadcast();
  Stream<LinkState> get stateStream => _stateCtrl.stream;

  LinkState _state = LinkState.disconnected;
  LinkState get state => _state;

  Future<void> connect() async {
    _update(LinkState.connecting);
    try {
      final res = await http
          .get(Uri.parse('${AppConfig.backendBaseUrl}/api/health'))
          .timeout(const Duration(seconds: 4));
      _update(res.statusCode == 200 ? LinkState.connected : LinkState.error);
    } catch (_) {
      _update(LinkState.error);
    }
  }

  void disconnect() {
    _update(LinkState.disconnected);
  }

  Future<void> sendReading(RackSensorData d) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConfig.backendBaseUrl}/api/racks/$rackId/data'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'temperature': d.temperature,
              'humidity': d.humidity,
              'power': d.power,
              'door': d.isDoorOpen,
              'alert': d.isAlert,
              'timestamp': d.timestamp.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 4));
      _update((res.statusCode == 200 || res.statusCode == 201)
          ? LinkState.connected
          : LinkState.error);
    } catch (_) {
      _update(LinkState.error);
    }
  }

  // logica
  // logica
  /// Estado compartido de vinculacion: cual rack esta activo y si el enlace
  /// esta encendido. El reloj lo consulta para seguir al celular (y
  /// viceversa) sin necesitar un canal directo entre los dos.
  Future<Map<String, dynamic>?> fetchSession() async {
    try {
      final res = await http
          .get(Uri.parse('${AppConfig.backendBaseUrl}/api/session'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // logica
    }
    return null;
  }

  Future<void> pushSession({String? activeRackId, bool? linked}) async {
    try {
      final body = <String, dynamic>{};
      if (activeRackId != null) body['activeRackId'] = activeRackId;
      if (linked != null) body['linked'] = linked;
      await http
          .put(
            Uri.parse('${AppConfig.backendBaseUrl}/api/session'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // logica
    }
  }

  void _update(LinkState s) {
    _state = s;
    if (!_stateCtrl.isClosed) _stateCtrl.add(s);
  }

  void dispose() {
    _stateCtrl.close();
  }
}
