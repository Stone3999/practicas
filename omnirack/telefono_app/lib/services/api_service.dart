import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/rack.dart';
import '../models/rack_sensor_data.dart';

class ApiService {
  Future<List<Rack>> getRacks() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.racks()));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        // logica
        final List<dynamic> racksList = body['racks'] ?? [];
        return racksList.map((rack) => Rack.fromJson(rack as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // logica
    }
    return [];
  }

  Future<Rack?> getRack(String id) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.rack(id)));
      if (response.statusCode == 200) {
        return Rack.fromJson(json.decode(response.body));
      }
    } catch (e) {
      // logica
    }
    return null;
  }

  Future<bool> sendRackData(String id, RackSensorData data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.rackData(id)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'temperature': data.temperature,
          'humidity': data.humidity,
          'power': data.power,
          'door': data.isDoorOpen,
          'alert': data.alert,
          'timestamp': data.timestamp.toIso8601String(),
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
  
  Future<List<dynamic>> getAlerts() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.alerts()));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        // logica
        return body['alerts'] ?? [];
      }
    } catch (e) {
      // logica
    }
    return [];
  }

  Future<bool> acknowledgeAlert(String id) async {
    try {
      final response = await http.post(Uri.parse(ApiConfig.alertAck(id)));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // logica
  // logica
  /// Estado compartido de vinculacion (rack activo + encendido/apagado) que
  /// el reloj y el celular leen y escriben para quedar sincronizados.
  Future<Map<String, dynamic>?> getSession() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.session()));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // logica
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateSession({String? activeRackId, bool? linked}) async {
    try {
      final body = <String, dynamic>{};
      if (activeRackId != null) body['activeRackId'] = activeRackId;
      if (linked != null) body['linked'] = linked;
      final response = await http.put(
        Uri.parse(ApiConfig.session()),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // logica
    }
    return null;
  }

  Future<String?> generateToken() async {
    try {
      final response = await http.post(Uri.parse(ApiConfig.authToken()));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['token'];
      }
    } catch (e) {
      // logica
    }
    return null;
  }
}
