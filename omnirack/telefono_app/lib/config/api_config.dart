import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
  }

  static String racks() => '$baseUrl/api/racks';
  static String rack(String id) => '$baseUrl/api/racks/$id';
  static String rackData(String id) => '$baseUrl/api/racks/$id/data';
  static String alerts() => '$baseUrl/api/alerts';
  static String alertAck(String id) => '$baseUrl/api/alerts/$id/ack';
  static String authToken() => '$baseUrl/api/auth/token';
}
