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
4. **Si ya lo tenías corriendo de una sesión anterior, reinícialo** (`Ctrl+C` y
   `npm start` de nuevo) cada vez que actualices el código del backend — Node
   no recarga las rutas solo. Puedes confirmar que tiene la versión más
   reciente probando `http://<tu-ip-local>:3000/api/session`; si responde
   `{"error":"endpoint no existe"}` es que sigue corriendo el código viejo.

### Paso 2: Abrir la Smart TV (PWA)
1. Abre tu navegador (Google Chrome o Edge).
2. Entra a `http://10.13.37.184:3000/`.
3. Presiona `F11` para poner la pantalla completa.
4. Presiona `F12` para abrir las DevTools, ve al icono de "Toggle device toolbar" (Emulación de móvil/tablet) y selecciona la resolución de **1920x1080** para simular la TV. Verás la interfaz dorada del Grid 2x2.

### Paso 3: Encender el Teléfono (Flutter App)
1. Abre una segunda terminal y navega al teléfono:
   ```bash
   cd telefono_app
   ```
2. Asegúrate de tener tu emulador de celular corriendo (ej. Pixel 6, API 36).
3. Verifica que `telefono_app/.env` apunte a la IP local del backend (`API_BASE_URL`), la misma que usaste en el Paso 2.
4. Lanza la aplicación en modo release (o debug si prefieres instalar directamente el APK):
   ```bash
   flutter run
   ```

### Paso 4: Encender el Wearable (Flutter Wear OS)
1. Abre una tercera terminal y navega al wearable:
   ```bash
   cd wearable_app
   ```
2. Asegúrate de tener tu emulador de reloj Wear OS corriendo (forma redonda/cuadrada).
3. Verifica que `wearable_app/lib/config/app_config.dart` (`backendBaseUrl`) apunte a la misma IP local del backend.
4. Lanza la aplicación:
   ```bash
   flutter run
   ```
5. El reloj mostrará "Toca Conectar para vincular".

### Paso 5: ¡Un solo botón en cada dispositivo! (El Clímax de la Demo)
Ya no hay BLE ni diálogos de emparejamiento: el reloj y el teléfono se vinculan
por **IP local** directamente contra el backend (el mismo que alimenta a la TV).
El backend guarda una **sesión compartida** (`/api/session`: qué rack está
activo y si el enlace está encendido) que ambos dispositivos consultan cada
2 segundos, así quedan sincronizados sin importar quién actúe primero.

1. En el **Teléfono**, elige el **Data Center** (chips DC-A a DC-D) arriba del
   botón — esto define el rack activo (`DC-<X>-RACK-01`).
2. Toca **"Conectar"** en el Teléfono (Dashboard o Configuración → "Vincular
   Wearable"). El teléfono enciende la sesión y empieza a leer ese rack del backend.
3. El **Reloj** detecta la sesión encendida en su siguiente ciclo (≤2 s) y
   **arranca solo**: genera lecturas del rack activo y las envía al backend por HTTP.
   También puedes tocar el ícono de enlace en el reloj para encender/apagar
   la sesión desde ahí; el teléfono lo reflejará igual.
4. Voltea a ver tu **Teléfono** y tu **Smart TV**; verás cómo los datos saltan y
   se sincronizan en vivo, porque los 3 dispositivos leen/escriben contra la misma fuente.
5. Para terminar, toca **"Detener"** en el Teléfono (o el ícono del reloj):
   apaga la sesión compartida y **el otro dispositivo se detiene solo** en su
   siguiente ciclo — no hace falta pararlos por separado.
6. Si cambias de Data Center en el Teléfono mientras ya estás conectado, el
   cambio se empuja de inmediato y el Reloj se cambia de rack en su siguiente
   ciclo, sin tocarlo.

---

> **Nota de Seguridad y Estabilidad:**
> No apagues el Backend durante la simulación. Reloj y Teléfono deben poder alcanzar
> por red la IP local del backend (misma red Wi-Fi/host); si el backend no responde,
> el botón "Conectar" mostrará estado de error y podrás reintentar sin reiniciar
> la app. Si acabas de actualizar el código del backend, revisa el Paso 1.4 antes
> de asumir que algo en las apps está mal.
