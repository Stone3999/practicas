# OMNIRACK — Sistema de Gestión Térmica para Data Centers

El ecosistema OMNIRACK es una solución integral IoT para el monitoreo y gestión de las condiciones térmicas de los racks en un Data Center. Se compone de 3 dispositivos principales:

1.  **Wearable App (Wear OS)**: Aplicación para smartwatches que simula métricas de sensores (temperatura, humedad, consumo de energía, estado de la puerta) y las envía directo al backend por HTTP sobre la red local (IP), sin BLE.
2.  **Teléfono App (Android)**: Aplicación móvil de administración y monitoreo. Lee los datos del rack activo directo del backend por HTTP (polling) sobre la misma red local.
3.  **Smart TV Dashboard (PWA/Web)**: Interfaz de monitoreo en tiempo real diseñada para pantallas grandes (Smart TVs), que recibe actualizaciones del backend vía Server-Sent Events (SSE).

## Arquitectura

Reloj y celular ya no se hablan por Bluetooth: ambos son clientes HTTP del
mismo backend, que además guarda una **sesión compartida** (`/api/session`:
rack activo + encendido/apagado) para que quedar sincronizados no dependa de
un enlace directo entre los dos dispositivos.

```text
 Wearable App                                          Teléfono App
 (Sensores)                                             (Monitoreo)
      |                                                       |
      |  HTTP POST /api/racks/:id/data (lecturas, c/1s)        |  HTTP GET /api/racks/:id (polling, c/1s)
      |  GET/PUT /api/session (rack activo, on/off, c/2s)      |  GET/PUT /api/session (c/2s)
      v                                                       v
                    +-------------------------------+
                    |         Backend Server          |
                    |   (Node.js/Express + sesión)    |
                    +-------------------------------+
                                    |
                                    | SSE (Server-Sent Events)
                                    v
                          +-------------------+
                          |    Smart TV App    |
                          |    (Dashboard)     |
                          +-------------------+
```

Conectar/Detener o cambiar de Data Center en el reloj o el celular actualiza
la sesión del backend; el otro dispositivo lo detecta en su siguiente
ciclo de polling (≤2s) y se ajusta solo — sin enlace directo entre ambos.

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
`http://10.13.37.184:3000`

## Configuración .env

El proyecto requiere archivos `.env` para la configuración. **NUNCA** incluyas claves reales en el código fuente.

**Ejemplo de `.env` para el Backend (`omnirack/backend/.env`):**
```env
PORT=3000
DATA_RETENTION_DAYS=30
SECRET_KEY=tu_clave_secreta_aqui
```

**Ejemplo de `.env` para `telefono_app` (`omnirack/telefono_app/.env`):**
```env
API_BASE_URL=http://tu-ip-local:3000
DEFAULT_RACK_ID=DC-A-RACK-01
```
*El wearable no usa `.env`: su IP de backend y rack por defecto están en
`omnirack/wearable_app/lib/config/app_config.dart` — deben apuntar a la misma
IP local que `API_BASE_URL`.*

*Asegúrate de agregar los archivos `.env` al `.gitignore`.*

## Equipo
*   Stone3999
*   DEQR

## Licencia
MIT License
