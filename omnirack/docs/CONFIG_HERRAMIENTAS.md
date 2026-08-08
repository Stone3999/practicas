# Configuración de Herramientas y Dependencias

Este documento especifica las versiones exactas y las herramientas utilizadas para el desarrollo de OMNIRACK.

## Herramientas Base

*   **Flutter SDK**: 3.44.0 (channel master)
*   **Dart SDK**: 3.12.0
*   **Android Studio**: Hedgehog (última versión)
*   **VS Code (Extensiones)**: Flutter, Dart, Live Server
*   **ffmpeg**: Instalado vía winget (`winget install Gyan.FFmpeg`)
*   **Node.js**: v22.22.0
*   **npm**: v10.x

## Dependencias Clave y Versiones

### Frontend (Flutter - Wearable y Teléfono)
*   `flutter_blue_plus`: ^1.32.12 (Comunicación Bluetooth Low Energy)
*   `ble_peripheral`: ^2.4.0 (Emulación de periférico BLE en Wearable)
*   `provider`: ^6.1.2 (Gestión de estado)
*   `http`: ^1.2.1 (Peticiones HTTP al backend)
*   `flutter_dotenv`: ^5.1.0 (Lectura de variables de entorno)

### Backend (Node.js)
*   `express`: ^4.19.2 (Framework de servidor)
*   `cors`: ^2.8.5 (Cross-Origin Resource Sharing)
*   `dotenv`: ^16.4.5 (Gestión de variables de entorno)

## Pasos de Instalación Rápida

1.  Asegurar que Node.js (v22.22.0) y Flutter (3.44.0) están instalados y en el PATH.
2.  Instalar ffmpeg si es necesario para utilidades multimedia en el servidor:
    ```powershell
    winget install Gyan.FFmpeg
    ```
3.  Para el backend:
    ```bash
    cd omnirack/backend
    npm install
    ```
4.  Para las aplicaciones Flutter:
    ```bash
    cd omnirack/wearable_app
    flutter pub get
    
    cd ../telefono_app
    flutter pub get
    ```
