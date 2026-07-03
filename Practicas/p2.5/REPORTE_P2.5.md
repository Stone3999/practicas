# Practica 2.5 - API OpenWeatherMap + APK Firmado

**Desarrollo para Dispositivos Inteligentes | Mayo - Agosto 2026**

---

## 1. Configuracion del Entorno

### 1.1 Dependencias agregadas

Se agregaron las siguientes dependencias en `pubspec.yaml`:

- `http: ^1.2.1` - Llamadas HTTP a la API
- `flutter_dotenv: ^5.1.0` - Lectura de variables de entorno desde `.env`
- Asset `.env` incluido en `flutter:` > `assets:`

## 2. Arquitectura Implementada

### 2.1 Capa de Configuracion - `lib/config/app_config.dart`

Clase centralizada que lee las variables de entorno via `flutter_dotenv` y valida que esten configuradas.

### 2.2 Modelo - `lib/models/weather.dart`

Modelo `Weather` con deserializacion JSON segura:
- Validacion de campos obligatorios (`main`, `weather`)
- Manejo de tipos (`num`, `int`, `double`)
- Valores por defecto seguros

### 2.3 Servicio HTTP - `lib/services/weather_service.dart`

`WeatherService` con:
- Sanitizacion de entrada (solo letras, numeros y espacios)
- Construccion de URL con parametros: `q`, `appid`, `units=metric`, `lang=es`
- Timeout de 10 segundos
- Manejo de todos los codigos HTTP:
  - `200` - Exito
  - `401` - API key invalida
  - `404` - Ciudad no encontrada
  - `429` - Limite de llamadas excedido
- Manejo de excepciones:
  - `SocketException` - Sin conexion
  - `TimeoutException` - Tiempo agotado
  - `FormatException` - Respuesta inesperada

### 2.4 Provider - `lib/providers/weather_provider.dart`

Estados manejados:
- `_isLoading` - Indicador de carga
- `_error` - Mensaje de error
- `_weather` - Datos del clima

### 2.5 UI - `lib/screens/home_screen.dart`

Pantalla principal con:
- Busqueda de ciudades por nombre
- Visualizacion de: ciudad, temperatura, descripcion, humedad y viento
- Indicador de carga (CircularProgressIndicator)
- Pantalla de error con icono, mensaje y boton de reintentar
- Carga automatica de Queretaro al iniciar

### 2.6 Entry Point - `lib/main.dart`

- Carga de `.env` con `await dotenv.load()` **antes** de `runApp()`
- Provider configurado via `ChangeNotifierProvider`

---

## 3. Generacion de APK Firmado

### 3.1 Keystore

Creado con keytool:

```
keytool -genkey -v -keystore climate_app.jks -keyalg RSA -keysize 2048 -validity 10000 -alias climate_key
```

- Archivo: `android/app/climate_app.jks`
- Password: guardada en lugar seguro

### 3.2 Configuracion Gradle

Las contraseñas se almacenan en `android/key.properties` (excluido de Git):

```properties
keyPassword=<password_del_keystore>
storePassword=<password_del_keystore>
```

Firma configurada en `android/app/build.gradle.kts` leyendo desde el archivo de propiedades:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keyProps = Properties()
val keyFile = rootProject.file("key.properties")
if (keyFile.exists()) {
    keyProps.load(FileInputStream(keyFile))
}

// Dentro de signingConfigs:
signingConfigs {
    create("release") {
        keyAlias = "climate_key"
        keyPassword = keyProps.getProperty("keyPassword") ?: ""
        storeFile = file("climate_app.jks")
        storePassword = keyProps.getProperty("storePassword") ?: ""
    }
}
```

- `key.properties` esta en `.gitignore` (nunca se sube al repositorio)
- Si el archivo no existe, el build falla con valores vacios (no hay fallback inseguro)
- Sin `key.properties` no se puede generar un APK release

### 3.3 APK Generado

```
flutter build apk --release
```

- Ruta: `build/app/outputs/flutter-apk/app-release.apk`
- Tamano: 47.0 MB
- Resultado: BUILD SUCCESSFUL

---

## 4. Verificacion de Seguridad

- API key en `.env`, no en codigo fuente
- `.env` excluido de Git (`.gitignore`)
- `*.jks` excluido de Git
- `flutter analyze` sin errores ni warnings

---

## 5. Evidencias

### 5.1 Analisis de codigo

```
$ flutter analyze
Analyzing p2.5...
No issues found! (ran in 4.2s)
```

### 5.2 APK generado

```
$ flutter build apk --release
√ Built build\app\outputs\flutter-apk\app-release.apk (47.0MB)
```
