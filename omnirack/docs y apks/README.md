# OMNIRACK — Sistema de Gestión Térmica para Data Centers

El ecosistema OMNIRACK es una solución integral IoT para el monitoreo y gestión de las condiciones térmicas de los racks en un Data Center. Se compone de 3 dispositivos principales:

1.  **Wearable App (Wear OS)**: Aplicación para smartwatches que simula o recolecta métricas de sensores (temperatura, humedad, consumo de energía, estado de la puerta) y las transmite vía BLE.
2.  **Teléfono App (Android)**: Aplicación móvil que actúa como gateway. Se conecta al wearable por BLE para recibir los datos y los envía al backend mediante peticiones HTTP.
3.  **Smart TV Dashboard (PWA/Web)**: Interfaz de monitoreo en tiempo real diseñada para pantallas grandes (Smart TVs), que recibe actualizaciones del backend vía Server-Sent Events (SSE).

## Arquitectura

```text
+-------------------+       BLE        +------------------+       HTTP       +-------------------+
|                   |  (Bluetooth)     |                  |  (REST/JSON)     |                   |
|  Wearable App     | ---------------> |  Teléfono App    | ---------------> |  Backend Server   |
|  (Sensores)       |                  |  (Gateway)       |                  |  (Node.js/Express)|
+-------------------+                  +------------------+                  +-------------------+
                                                                                      |
                                                                                      | SSE (Server-Sent Events)
                                                                                      v
                                                                             +-------------------+
                                                                             |                   |
                                                                             |  Smart TV App     |
                                                                             |  (Dashboard)      |
                                                                             +-------------------+
```

## Requisitos Previos (Prerequisites)

*   **Flutter**: 3.44.0
*   **Dart**: 3.12.0
*   **Node.js**: v22.22.0
*   **ffmpeg**: Instalado y en el PATH

## Instrucciones de Instalación (Setup)

### 1. Backend Server
```bash
cd omnirack/backend
npm install
npm start
```
*El servidor correrá por defecto en el puerto 3000.*

### 2. Wearable App
```bash
cd omnirack/wearable_app
flutter pub get
flutter run
```
*Desplegar en emulador de Wear OS.*

### 3. Teléfono App
```bash
cd omnirack/telefono_app
flutter pub get
flutter run
```
*Desplegar en emulador de teléfono o dispositivo físico.*

### 4. Smart TV App
El Dashboard PWA es servido directamente por el backend. Al iniciar el backend, se puede acceder abriendo un navegador en:
`http://localhost:3000`

## Configuración .env

El proyecto requiere archivos `.env` para la configuración. **NUNCA** incluyas claves reales en el código fuente.

**Ejemplo de `.env` para el Backend (`omnirack/backend/.env`):**
```env
PORT=3000
DATA_RETENTION_DAYS=30
SECRET_KEY=tu_clave_secreta_aqui
```

**Ejemplo de `.env` para las apps Flutter:**
```env
API_URL=http://tu-ip-local:3000
```
*Asegúrate de agregar los archivos `.env` al `.gitignore`.*

## Equipo
*   Stone3999
*   DEQR

## Licencia
MIT License
