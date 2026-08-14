# Configuración de Emuladores

Para probar todo el ecosistema localmente, se requiere configurar los siguientes entornos virtuales:

## Emuladores Recomendados

1.  **Phone Emulator (Android)**
    *   **Dispositivo**: Pixel 7 (o similar)
    *   **OS**: API 34 (Android 14)
    *   **Memoria**: 2GB RAM
    *   **Uso**: Ejecutar `telefono_app`. Lee el rack activo directo del backend por HTTP (IP local).

2.  **Wear OS Emulator**
    *   **Dispositivo**: Wear OS Round
    *   **OS**: API 33 (Wear OS 4)
    *   **Memoria**: 1GB RAM
    *   **Uso**: Ejecutar `wearable_app`. Genera las lecturas del sensor y las envía directo al backend por HTTP (IP local).

3.  **Smart TV Dashboard (Chrome DevTools)**
    *   **Resolución**: 1920x1080 (HD)
    *   **User Agent**: Configurar custom user agent como Smart TV.
    *   **Uso**: Abrir `http://10.13.37.184:3000` en el navegador y usar el Device Mode (F12) para emular la pantalla de la TV y la navegación con teclado (D-pad).

## Solución de Problemas Frecuentes (Troubleshooting)

*   **BLE entre emuladores en Windows (por qué el ecosistema ya no usa BLE):**
    *   *Problema*: La comunicación BLE directa entre el emulador de teléfono y el emulador de Wear OS **NO está soportada** nativamente en Windows.
    *   *Solución adoptada*: se reemplazó el enlace BLE reloj↔celular por vinculación
        **por IP local**: ambos dispositivos son clientes HTTP del mismo backend
        (lecturas + una sesión compartida en `/api/session`), así que la
        limitación de BLE en emuladores de Windows deja de ser un problema.
*   **El reloj y el celular no se sincronizan (`Error de conexión` / el reloj no arranca):**
    *   *Problema*: el backend no tiene cargadas las rutas de `/api/session`
        (código desactualizado) o el rack seleccionado no existe en el backend.
    *   *Solución*: reinicia el backend (`Ctrl+C` + `npm start`) después de
        actualizar su código, y confirma que `telefono_app/.env`
        (`DEFAULT_RACK_ID`) y `wearable_app/lib/config/app_config.dart`
        (`defaultRackId`) usan un rack real (ver `GET /api/racks`, ej.
        `DC-A-RACK-01`).
*   **Corrupción de Caché en Kotlin/Gradle:**
    *   *Problema*: Errores extraños de compilación en Android Studio o CLI de Flutter.
    *   *Solución*: Ejecutar `flutter clean` y eliminar manualmente la carpeta `.gradle` en la raíz del proyecto y en `android/.gradle`.
*   **FFmpeg no encontrado:**
    *   *Problema*: Al intentar usar características multimedia, el sistema no encuentra el binario de ffmpeg.
    *   *Solución*: Instalar utilizando el gestor de paquetes de Windows: `winget install Gyan.FFmpeg` y asegurarse de reiniciar la terminal para actualizar el PATH.
