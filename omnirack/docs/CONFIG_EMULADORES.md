# Configuración de Emuladores

Para probar todo el ecosistema localmente, se requiere configurar los siguientes entornos virtuales:

## Emuladores Recomendados

1.  **Phone Emulator (Android)**
    *   **Dispositivo**: Pixel 7 (o similar)
    *   **OS**: API 34 (Android 14)
    *   **Memoria**: 2GB RAM
    *   **Uso**: Ejecutar `telefono_app`. Actuará como gateway BLE a HTTP.

2.  **Wear OS Emulator**
    *   **Dispositivo**: Wear OS Round
    *   **OS**: API 33 (Wear OS 4)
    *   **Memoria**: 1GB RAM
    *   **Uso**: Ejecutar `wearable_app`. Actuará como el sensor periférico BLE.

3.  **Smart TV Dashboard (Chrome DevTools)**
    *   **Resolución**: 1920x1080 (HD)
    *   **User Agent**: Configurar custom user agent como Smart TV.
    *   **Uso**: Abrir `http://localhost:3000` en el navegador y usar el Device Mode (F12) para emular la pantalla de la TV y la navegación con teclado (D-pad).

## Solución de Problemas Frecuentes (Troubleshooting)

*   **BLE entre emuladores en Windows:**
    *   *Problema*: La comunicación BLE directa entre el emulador de teléfono y el emulador de Wear OS **NO está soportada** nativamente en Windows.
    *   *Solución*: Utilizar un sistema de simulación/fallback por software dentro de las aplicaciones cuando se detecte que corren en emuladores (o usar un dispositivo físico Android).
*   **Corrupción de Caché en Kotlin/Gradle:**
    *   *Problema*: Errores extraños de compilación en Android Studio o CLI de Flutter.
    *   *Solución*: Ejecutar `flutter clean` y eliminar manualmente la carpeta `.gradle` en la raíz del proyecto y en `android/.gradle`.
*   **FFmpeg no encontrado:**
    *   *Problema*: Al intentar usar características multimedia, el sistema no encuentra el binario de ffmpeg.
    *   *Solución*: Instalar utilizando el gestor de paquetes de Windows: `winget install Gyan.FFmpeg` y asegurarse de reiniciar la terminal para actualizar el PATH.
