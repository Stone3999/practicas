# Ecosistema OmniRack — Monitor IoT de Data Centers

Ecosistema de 3 dispositivos (Teléfono, Wearable, y PWA para Smart TV) operando simultáneamente para el monitoreo térmico y eléctrico de infraestructura en tiempo real.

## 🚀 Instrucciones para ejecutar el stack completo (Demo)

Sigue estos pasos en el orden exacto para encender el ecosistema de OmniRack y tener los 3 dispositivos sincronizados para tu evaluación.

### Paso 1: Levantar el Backend (El Cerebro)
1. Abre una terminal y navega a la carpeta del backend:
   ```bash
   cd backend
   ```
2. Instala dependencias si no lo has hecho: `npm install`
3. Arranca el servidor Node.js:
   ```bash
   npm start
   ```
   *(Asegúrate de que te diga que está corriendo en el puerto 3000)*.

### Paso 2: Abrir la Smart TV (PWA)
1. Abre tu navegador (Google Chrome o Edge).
2. Entra a `http://localhost:3000/`.
3. Presiona `F11` para poner la pantalla completa.
4. Presiona `F12` para abrir las DevTools, ve al icono de "Toggle device toolbar" (Emulación de móvil/tablet) y selecciona la resolución de **1920x1080** para simular la TV. Verás la interfaz dorada del Grid 2x2.

### Paso 3: Encender el Teléfono (Flutter App)
1. Abre una segunda terminal y navega al teléfono:
   ```bash
   cd telefono_app
   ```
2. Asegúrate de tener tu emulador de celular corriendo (ej. Pixel 6, API 36).
3. Lanza la aplicación en modo release (o debug si prefieres instalar directamente el APK):
   ```bash
   flutter run
   ```

### Paso 4: Encender el Wearable (Flutter Wear OS)
1. Abre una tercera terminal y navega al wearable:
   ```bash
   cd wearable_app
   ```
2. Asegúrate de tener tu emulador de reloj Wear OS corriendo (forma redonda/cuadrada).
3. Lanza la aplicación:
   ```bash
   flutter run
   ```
4. El reloj mostrará "Esperando configuración...".

### Paso 5: ¡Vincular y hacer la Magia! (El Clímax de la Demo)
1. Ve a la app de tu **Teléfono** y navega a la pestaña de abajo a la derecha (**Configuración** ⚙️).
2. Toca en **"Vincular Wearable"**.
3. Selecciona el Data Center (ej. Data Center A) y el Rack.
4. Presiona **"Vincular"**. 
5. Inmediatamente el **Wearable** despertará y mostrará la temperatura, un checkmark verde y el nombre del rack.
6. **Importante:** ¡Dale tap al botón de **Play** (el triángulo en el reloj) para que comience a emitir datos cada 1 segundo!
7. Voltea a ver tu **Teléfono** y tu **Smart TV**; verás cómo los datos saltan y se sincronizan armónicamente en vivo por arte de magia.

---

> **Nota de Seguridad y Estabilidad:**
> No apagues el Backend durante la simulación. Si la app del celular marca error de Bluetooth en Windows, entrará en modo de emulación automática simulando los datos, garantizando que tu presentación no falle.
