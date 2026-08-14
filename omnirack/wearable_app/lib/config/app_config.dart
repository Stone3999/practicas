// logica
// logica
// logica
/// Direccion local del backend OMNIRACK. Debe apuntar a la misma IP/puerto
/// configurados en telefono_app/.env (API_BASE_URL) para que el reloj, el
/// celular y la TV vean siempre los mismos datos (todo en la red local).
class AppConfig {
  static const String backendBaseUrl = 'http://10.13.37.184:3000';
  static const String defaultRackId = 'DC-A-RACK-01';
}
