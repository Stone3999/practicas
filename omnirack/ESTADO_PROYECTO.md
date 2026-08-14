# OMNIRACK — Estado del proyecto y lista de cotejo

> Documento de seguimiento del ecosistema de 3 dispositivos.
> Actualizado: 13 de agosto de 2026 · Nivel objetivo: **AU (100)**
>
> ⚠️ **Cambio de arquitectura (13 ago 2026):** el enlace reloj↔celular por BLE
> se reemplazó por vinculación **IP local** (HTTP directo al backend + una
> sesión compartida). Ver el punto 6 de "Decisiones acordadas" y la sección
> "Fase 2/3 (actualización)" más abajo — los checklists de BLE (SA.1.A/B)
> quedan documentados como estaban, con una nota de qué sigue vigente y qué no.

---

## 1. Premisa del proyecto

**OMNIRACK** es un sistema de gestión, control térmico y uso adecuado de energía para
Data Centers e infraestructuras de servidores críticos. Detecta y resuelve problemas
de manera **síncrona**, combinando:

| Dispositivo | Rol en el ecosistema |
|---|---|
| **Smartwatch (Wear OS)** | Alertas **táctiles** (entorno ruidoso), indica el RACK afectado + descripción rápida, botón para **confirmar la alerta** y unirse al equipo de solución. |
| **Smartphone (Flutter)** | **Administración y seguridad**: configura umbrales del rack, resguarda IPs de servidores (LFPDPPP) y genera **tokens dinámicos** para autorizar cambios. |
| **Smart TV (PWA)** | **Monitoreo pasivo**: muestra todos los datos en tiempo real; ante una alerta muestra cámara del rack, el problema y las especificaciones del rack. |

### Arquitectura del ecosistema

```
[Wearable - sensor del rack] ──HTTP POST (IP local)──> [Backend Node/Express] ──SSE──> [PWA Smart TV]
[Teléfono Flutter] ──HTTP GET/polling (IP local)──> [Backend Node/Express]
Ambos dispositivos leen/escriben además /api/session (rack activo + on/off)
para quedar sincronizados sin canal directo entre ellos.
```

El backend es ahora el **puente único**: el wearable le manda sus lecturas
por HTTP directo (ya no por BLE al teléfono), y el teléfono las lee del
mismo backend por polling. La TV se suscribe por SSE (tiempo real <2 s) y
usa BroadcastChannel para comunicación local. Se abandonó el enlace BLE
reloj↔celular porque BLE entre emuladores no funciona en Windows (ver punto
2 más abajo); la vinculación por IP local resuelve esa limitación y además
permite que "Detener" o cambiar de Data Center en cualquiera de los dos
dispositivos se refleje en el otro.

---

## 2. Decisiones acordadas

1. **Nivel objetivo: AU (100)** → SA completo + DE (Lighthouse, video demo) + SSE/WebSocket
   en tiempo real + tester externo + ciclo de vida de datos.
2. ~~**Demo BLE**: código BLE real (GATT NOTIFY) + fallback de simulación local en el
   teléfono cuando no hay dispositivo (BLE entre emuladores no funciona en Windows).~~
   **Superada el 13 ago 2026**: en vez de un fallback de simulación cuando BLE
   fallaba, se quitó BLE por completo. Reloj y celular son clientes HTTP del
   backend (misma IP local); un endpoint `/api/session` (GET/PUT) guarda el
   rack activo y si el enlace está encendido, y cada dispositivo lo consulta
   cada ~2s. Ventaja sobre el fallback anterior: ambos dispositivos muestran
   el **mismo dato real** (antes, sin BLE, cada uno simulaba su propio
   número al azar) y "Conectar/Detener" o cambiar de Data Center en uno se
   refleja en el otro automáticamente.
3. **ffmpeg instalado** vía winget (requisito del nivel DE y del reporte SA.6.A).
4. **Paleta OMNIMAN** (extraída de los mockups de Figma `p1.2` / `p1.3`):

| Rol | Color |
|---|---|
| Fondo | `#F8F8F8` (blanco) |
| Rojo de marca / barras / alerta | `#C81030` |
| Rojo oscuro (hover/activo) | `#A01828` / `#701828` |
| Precaución | `#E0B840` (amarillo) |
| Éxito / OK | `#40F000` (verde lima) |
| Texto | `#181818` (contraste AA sobre blanco) |
| Texto sobre rojo | `#FFFFFF` |
| Foco D-pad (TV) | `#FFD700` dorado (requisito checklist) |

5. **Seguridad crítica**: ninguna credencial en el código ni en el historial git
   (verificado: la API key no aparece en ningún commit; `.env`, `*.jks`,
   `key.properties`, `env.js` están en `.gitignore`).

---

## 3. Avance del trabajo (lo que ya se hizo)

### Fase 0 — Cimientos y seguridad ✅ COMPLETA
- Estructura creada en `omnirack/`: `backend/`, `wearable_app/`, `telefono_app/`, `smart_tv/`, `docs/`.
- **`.gitignore` raíz** creado en `Smart Device Development/` cubriendo:
  `.env`, `.env.*`, `*.jks`, `*.keystore`, `*.p12`, `key.properties`, `env.js`,
  `node_modules/`, `build/`, `.dart_tool/`, archivos temporales de Word, etc.
  (respeta `.env.example`).
- **Historial git verificado**: `git ls-files` → NO hay `.env`, `.jks`, `key.properties`
  ni `.keystore` rastreados en ningún commit. La API key real no aparece en ningún
  blob de texto del historial. ✅
- **Detectado**: existen 2 archivos basura de Word rastreados
  (`Practicas/~$áctica 1.1.docx`, `Practicas/~WRL0005.tmp`) — se limpiarán antes del release.
- **ffmpeg instalado** (winget, `Gyan.FFmpeg`).

### Fase 1 — Backend (API del caso de estudio) ✅ COMPLETA y PROBADA
Ubicación: `omnirack/backend/` (Node.js + Express).

**Endpoints implementados:**

| Método | Ruta | Función |
|---|---|---|
| GET | `/api/health` | Estado del servidor |
| GET | `/api/meta` | Política de retención / ciclo de vida |
| POST | `/api/data/purge` | Purga forzada por retención |
| GET | `/api/racks` | Lista de racks + última lectura |
| GET | `/api/racks/:id` | Detalle de rack |
| POST | `/api/racks` | Crear rack (requiere token) |
| PUT | `/api/racks/:id` | Actualizar umbrales/config (requiere token) |
| DELETE | `/api/racks/:id` | Eliminar rack (requiere token) |
| POST | `/api/racks/:id/data` | Recibir datos del teléfono (BLE→API) + evaluar umbrales |
| GET | `/api/racks/:id/data` | Consultar lecturas (ciclo USO) |
| DELETE | `/api/racks/:id/data` | Eliminar datos de un rack (ciclo ELIMINACIÓN) |
| GET | `/api/alerts` | Historial de alertas |
| POST | `/api/alerts/:id/ack` | Confirmar alerta (wearable/teléfono) |
| POST | `/api/auth/token` | Generar token dinámico (TTL 5 min, un solo uso) |
| GET | `/api/auth/tokens` | Tokens activos |
| DELETE | `/api/auth/tokens` | Revocar todos los tokens |
| GET | `/api/events/stream` | **SSE** en tiempo real (sensor + alertas) |

**Pruebas realizadas (todas pasaron):**
- Racks listados (4 racks seed: RACK-01..04).
- POST datos normales → `status: ok`.
- POST temp 36.4°C → **alerta** "Temperatura crítica".
- POST puerta abierta → **alerta** "Puerta del rack abierta".
- Token dinámico: PUT sin token → 401; con token → OK; reuso → 401 "token ya usado".
- ACK de alerta → OK; ACK repetido → 409.
- Ciclo de vida: lecturas consultadas, conteos correctos.
- **SSE verificado**: eventos `sensor` y `alert` llegan en vivo.
- Datos UTF-8 correctos (símbolo ° = `C2 B0`).

**Ciclo de vida de datos (AU):**
- Creación → `POST /:id/data` / `POST /racks`.
- Uso → `GET /:id/data`, `GET /alerts`, `GET /racks`.
- Retención → cron cada hora aplica `DATA_RETENTION_DAYS` (30) + `POST /api/data/purge`.
- Eliminación → `DELETE /:id/data`, `DELETE /racks/:id`.

### Fase 2 — App Wearable (Wear OS) ⏳ EN CURSO
Ubicación: `omnirack/wearable_app/` (copiada y adaptada de `Practicas/p2.6/wearable_app`).

**Cambios aplicados:**
- **UUIDs OMNIRACK nuevos** (servicio `6f6d6e69-7261-636b-2d73-656e736f7273` = "omnirack-sensors"):
  - `temperature` (float IEEE754, 4 bytes LE)
  - `humidity` (uint8)
  - `power` (float IEEE754, 4 bytes LE)
  - `door` (string utf8 OPEN/CLOSED)
  - `alert` (uint8 0/1)
  - Todos con propiedad **NOTIFY** (+ READ).
- **`SensorSimulator`** nuevo: genera 1 lectura/segundo de temperatura, humedad,
  consumo (kW), puerta y bandera de alerta (umbrales del caso de estudio:
  temp ≥35°C, humedad fuera de [10,85]%, consumo ≥9.5 kW, puerta abierta).
- **`RackSensorData`** modelo compartido.
- **UI wearable** con tema OMNIMAN (fondo blanco, rojo `#C81030`, verde/giallo de estado):
  chip NORMAL/ALERTA, temperatura gigante, humedad/consumo, estado de puerta,
  botón **Iniciar/Detener**, indicador "Enviando".
- **Ícono propio OMNIRACK** generado (emblema "O" rojo sobre fondo blanco) en los
  5 tamaños mipmap (48/72/96/144/192).
- **Config Wear OS**: `uses-feature android.hardware.type.watch`, label "OmniRack",
  `applicationId com.omnirack.wearable`.
- `flutter analyze` → **0 issues** ✅
- `flutter test` → **pasó** ✅

**Pendiente en Fase 2:**
- ⚠️ `flutter build apk --debug` falló por **caché incremental de Kotlin corrupta**
  del plugin `ble_peripheral` (causado por un build interrumpido, no por el código).
  Se hizo `flutter clean` + limpieza de `android/.gradle` y se está reconstruyendo.

---

## 4. Lo que falta (pendiente)

| Fase | Descripción | Estado |
|---|---|---|
| **Fase 3** | `telefono_app/`: BleClient por serviceUUID, parseo binario, RackProvider, 3+ métricas, alertas por umbral, estados de conexión, HTTP al backend, sin crash al desconectar | Pendiente |
| **Fase 4** | `smart_tv/` PWA: 1920x1080, safe zone 5%, sin scroll, grid 2x2, D-pad + foco dorado, SSE, BroadcastChannel + `event.origin`, CSP, SW (Cache First/Network First), splash, lazy loading, videos ffmpeg <5MB + fallback | Pendiente |
| **Fase 5** | Integración de los 3 dispositivos simultáneos + cámara del rack con fallback | Pendiente |
| **Fase 6** | Documentación: README, seguridad LFPDPPP, aviso de privacidad, plan de pruebas (10+ casos), reporte de configuración (herramientas + emuladores), Lighthouse, video demo | Pendiente |
| **Fase 7** | Release v1.0, APK firmado, limpieza de archivos basura de Word, verificación git final | Pendiente |

---

## 5. Lista de cotejo (criterios de evaluación)

> Cuatrimestre Mayo–Agosto 2026 · Evaluación 2 — Ecosistema completo: Teléfono + Wearable + Smart TV.

### Estructura de la evaluación

| Nivel | Puntos | Lo que se evalúa | Prerrequisito |
|---|---|---|---|
| SA — Satisfactorio | 80 | PWA TV funcional con datos reales + 3 dispositivos conectados + documentación completa | Asistencias y Prácticas (>80%) |
| DE — Destacado | 90 | SA + Lighthouse > 80 + video demo del ecosistema | Cumplir 100% SA |
| AU — Autónomo | 100 | DE + WebSocket/SSE en tiempo real + tester externo + ciclo de vida de datos | Cumplir 100% DE |

> ⚠️ El nivel de la Evaluación 1 condiciona el máximo alcanzable en la 2.

---

### SA.1.A — App wearable (Wear OS emulado)

| Elemento a evaluar | Cumplido |
|---|---|
| Proyecto Wear OS separado (`wearable_app/`) compila sin errores en emulador Wear OS | ☐ (build en curso) |
| Ícono de aplicación propio (no el default de Flutter) configurado (Formato: PNG/mipmap) | ✅ |
| Simulador de sensores genera datos del caso de estudio cada segundo (Datos: temp, humedad, consumo, puerta, alerta) | ✅ |
| Al menos 3 tipos de datos generados | ✅ |
| Pantalla del wearable muestra datos localmente en tiempo real | ✅ |
| Botón Iniciar/Detener controla la generación de datos | ✅ (ahora es el botón único "Conectar/Detener", ver nota) |
| Características GATT expuestas con NOTIFY (no solo WRITE) para cada tipo de dato | ❌ *(superado 13 ago: ya no hay BLE; el wearable expone sus datos vía `HTTP POST /api/racks/:id/data` al backend)* |
| UUIDs de servicio y características definidos como constantes compartidas | ❌ *(ya no aplica; `ble_constants.dart` se eliminó — la config compartida ahora es `wearable_app/lib/config/app_config.dart`)* |

**Subtotal: 5/8** (bajó de 7/8 por el cambio a IP local; falta confirmar build en emulador)

---

### SA.1.B — App teléfono: recepción y visualización de datos del wearable

> ⚠️ Esta tabla se escribió pensando en BLE. Tras el cambio del 13 ago, léela
> con su equivalente por IP local: donde dice "BleClient/NOTIFY/bytes", el
> celular usa `RackLinkClient` (polling HTTP a `/api/racks/:id` cada 1s) y
> parsea JSON (`RackSensorData.fromJson`) en vez de bytes BLE. Falta una
> revisión formal fila por fila contra el rubric real (no se hizo en esta
> pasada, solo se dejó constancia del cambio de transporte).

| Elemento a evaluar | Cumplido |
|---|---|
| ~~BleClient escanea y encuentra el wearable por serviceUUID~~ → `RackLinkClient` hace polling HTTP al rack activo | ✅ (equivalente IP local) |
| ~~Suscripción a NOTIFY activa en cada característica~~ → polling `GET /api/racks/:id` cada 1s | ✅ (equivalente IP local) |
| ~~Los bytes recibidos se parsean según su tipo~~ → JSON parseado con `RackSensorData.fromJson` | ✅ (equivalente IP local) |
| ActivityProvider (o equivalente) acumula los datos y notifica a la UI | ✅ (`RackProvider`) |
| Widget de monitoreo muestra mínimo 3 métricas en tiempo real | ☐ (revisar contra rubric) |
| Alerta visible cuando un dato supera un umbral crítico (Umbral: temp ≥35°C, humedad fuera de rango, consumo ≥9.5 kW, puerta abierta) | ☐ (revisar contra rubric) |
| La UI muestra estado de conexión (buscando / conectado / error / desconectado) | ✅ (`ConnectionIndicator`, ya no dice "BLE") |
| Al desconectar el backend, la app no crashea y muestra mensaje de estado | ✅ (`LinkState.error`, reintenta solo) |

**Subtotal: 5/8** (pendiente revisar las 2 filas marcadas y confirmar con el rubric real si el cambio de BLE a IP local es aceptable para estos criterios)

---

### SA.2.A — PWA: estructura y configuración

| Elemento a evaluar | Cumplido |
|---|---|
| `manifest.json` válido: name, short_name, display: fullscreen, orientation: landscape | ☐ (Fase 4) |
| Íconos 192x192 y 512x512 PNG con purpose: any maskable | ☐ (Fase 4) |
| Service worker registrado y activo | ☐ (Fase 4) |
| Estrategia Cache First para estáticos y Network First para datos API | ☐ (Fase 4) |
| Modo offline: la app carga la estructura desde cache sin red | ☐ (Fase 4) |
| Content Security Policy en meta tag (default-src, connect-src, media-src) | ☐ (Fase 4) |
| `.gitignore` incluye .env y archivos sensibles; API key NO en ningún commit ⚠ | ✅ |
| **Subtotal: 1/7** | |

---

### SA.2.B — Layout 1920x1080 y diseño 10-foot

| Elemento a evaluar | Cumplido |
|---|---|
| Safe zone del 5% (54px vertical / 96px horizontal) | ☐ (Fase 4) |
| Sin scroll: overflow hidden, todo visible en 1080px | ☐ (Fase 4) |
| Grid de mínimo 4 elementos/registros en formato 2x2 | ☐ (Fase 4) |
| Tipografía dato principal ≥5rem (80px) visible desde 3 metros | ☐ (Fase 4) |
| Tipografía etiqueta secundaria ≥2rem (32px), detalle ≥1.5rem (24px) | ☐ (Fase 4) |
| Contraste texto/fondo WCAG AA (mínimo 4.5:1) | ☐ (Fase 4) |
| Foco visible D-pad: borde o glow dorado en la tarjeta activa | ☐ (Fase 4) |

**Subtotal: 0/7**

---

### SA.2.C — Navegación D-pad y datos reales

| Elemento a evaluar | Cumplido |
|---|---|
| Flechas de teclado mueven el foco entre elementos del grid | ☐ (Fase 4) |
| Enter/OK selecciona el elemento y actualiza el recurso multimedia de fondo | ☐ (Fase 4) |
| Al llegar al borde del grid, el foco no se rompe (límites) | ☐ (Fase 4) |
| Mínimo 4 registros/elementos con datos reales de la API | ☐ (Fase 4) |
| Cada tarjeta muestra datos del caso de estudio (mínimo 3 campos) | ☐ (Fase 4) |
| Recurso multimedia (video o imagen) cambia según el estado del elemento seleccionado | ☐ (Fase 4) |
| Fallback visual si el recurso multimedia no carga (imagen o color sólido) | ☐ (Fase 4) |
| Información contextual en el header (hora, fecha o identificador del proyecto) | ☐ (Fase 4) |

**Subtotal: 0/8**

---

### SA.3 — Integración del ecosistema (3 dispositivos)

| Elemento a evaluar | Cumplido |
|---|---|
| App Flutter teléfono muestra datos del caso de estudio desde la API en tiempo real (P2.5) | ✅ (polling HTTP a `/api/racks/:id`) |
| App wearable genera y envía datos al backend por IP local (P2.6) — *criterio original pedía BLE NOTIFY al teléfono, ver nota del 13 ago* | ✅ (equivalente IP local; ⚠️ confirmar con el profesor si el cambio de transporte es aceptable) |
| PWA Smart TV muestra datos sincronizados con el teléfono (P3.3) | ✅ (ambos leen del mismo backend/sesión) |
| Los 3 dispositivos activos SIMULTÁNEAMENTE durante la demo de 5 minutos | ☐ (Fase 5) |
| README.md actualizado con instrucciones de cómo ejecutar los 3 proyectos | ☐ (Fase 6) |
| Release v1.0 etiquetado en GitHub con descripción de cambios | ☐ (Fase 7) |
| Repositorio limpio: sin API keys, sin .jks, sin .env en el historial ⚠ | ✅ |
| **Subtotal: 4/7** | |

---

### SA.4 — Documentación de seguridad

| Elemento a evaluar | Cumplido |
|---|---|
| Validación de `event.origin` en BroadcastChannel documentada y aplicada | ☐ (Fase 4) |
| LFPDPPP: datos personales identificados con base legal documentada | ☐ (Fase 6) |
| Aviso de privacidad (responsable, datos, finalidad, derechos ARCO) | ☐ (Fase 6) |
| Plan de retención de datos (cuánto tiempo se guardan y cómo se eliminan) | ☐ (Fase 6) |
| Checklist de seguridad PWA: CSP, HTTPS, SRI, validación de origin | ☐ (Fase 6) |

**Subtotal: 0/5**

---

### SA.5 — Plan y reporte de pruebas

| Elemento a evaluar | Cumplido |
|---|---|
| Plan de pruebas: al menos 10 casos (incluye P2.5, P2.6 y P3.1-P3.4) | ☐ (Fase 6) |
| Prueba API (P2.5): teléfono muestra datos reales y maneja error de red | ☐ (Fase 6) |
| Prueba BLE NOTIFY (P2.6): datos del wearable llegan al teléfono en tiempo real | ☐ (Fase 6) |
| Prueba D-pad (PWA): todas las direcciones y Enter/OK | ☐ (Fase 6) |
| Prueba modo offline: el SW sirve la app sin red | ☐ (Fase 6) |
| Prueba de sincronización: cambio en teléfono se refleja en TV en <2 seg | ☐ (Fase 6) |
| Evidencia con screenshots de los 3 dispositivos (mínimo 5 capturas) | ☐ (Fase 6) |
| Documento firmado por el alumno con fecha | ☐ (Fase 6) |

**Subtotal: 0/8**

---

### SA.6.A — Reporte de configuración de herramientas

| Elemento a evaluar | Cumplido |
|---|---|
| Versión de Flutter SDK y Dart SDK documentada (`flutter --version`) | ☐ (Fase 6) |
| Versión de Android Studio y plugins (Flutter, Dart) | ☐ (Fase 6) |
| Herramientas Unidad 3: VS Code, extensiones, ffmpeg (versión) | ☐ (Fase 6) |
| Dependencias clave con versión (pubspec.yaml: flutter_blue_plus, http, provider, etc.) | ☐ (Fase 6) |
| Pasos de instalación reproducibles | ☐ (Fase 6) |

**Subtotal: 0/5**

---

### SA.6.B — Reporte de configuración de emuladores

| Elemento a evaluar | Cumplido |
|---|---|
| Emulador de teléfono documentado (modelo, API level, RAM) | ☐ (Fase 6) |
| Emulador Wear OS documentado (forma round/square, API level, RAM) | ☐ (Fase 6) |
| Emulación TV en Chrome DevTools documentada (1920x1080, user agent) | ☐ (Fase 6) |
| Capturas de cada emulador corriendo como evidencia | ☐ (Fase 6) |
| Troubleshooting real documentado | ☐ (Fase 6) |

**Subtotal: 0/5**

---

### Decisión Nivel SA — 80 puntos (para alcanzarlo)
- Mínimo 6/7 en SA.0.B (APK firmado e instalable)
- Mínimo 7/8 en SA.1.A (wearable generando datos e ícono propio) — ⚠️ bajó a 5/8 tras quitar BLE, revisar con el profesor
- Mínimo 7/8 en SA.1.B (teléfono recibe datos del wearable, ahora por IP local en vez de BLE NOTIFY)
- Mínimo 6/7 en SA.2.A (estructura PWA)
- Mínimo 6/7 en SA.2.B (layout 10-foot)
- Mínimo 7/8 en SA.2.C (navegación y datos reales)
- Mínimo 6/7 en SA.3 (ecosistema 3 dispositivos)
- Mínimo 4/5 en SA.4 (documentación de seguridad)
- Mínimo 7/8 en SA.5 (plan de pruebas)
- Mínimo 4/5 en SA.6.A (configuración de herramientas documentada)
- Mínimo 4/5 en SA.6.B (configuración de emuladores documentada)
- API key y archivos sensibles NUNCA en el repositorio (crítico)
- Los 3 dispositivos funcionales SIMULTÁNEAMENTE en la demo de 5 minutos

---

### Nivel DE — Destacado (90) [para AU: cumplir 100% DE]
- **DE.1 — Lighthouse y optimización** (8 elementos): Lighthouse >80 (Performance,
  A11y, Best Practices, SEO), FCP/LCP/TBT medidos, ARIA + foco programático,
  HTTPS/sin errores de consola/sin libs vulnerables, PWA checklist completo,
  videos ffmpeg H.264 faststart ≤5MB, lazy loading de videos, splash screen.
- **DE.2 — Video demo** (6 elementos): video de 5 min, voz explicando, muestra
  inicio en TV/búsqueda en teléfono/actualización en TV, pasos y ritmo cardíaco
  del wearable en el teléfono, subido como GitHub Release asset o enlace público,
  calidad suficiente.
- **DE.3 — Pruebas ampliadas** (4 elementos): resultados de Lighthouse como
  evidencia, pruebas de sincronización cronometradas, fallback si la API no responde,
  fallback si el video no carga.

### Nivel AU — Autónomo (100)
- DE + WebSocket/SSE en tiempo real (✅ ya implementado en el backend) +
  tester externo con reporte + ciclo de vida de datos (✅ ya implementado en el backend).

---

## 6. Datos del caso de estudio (OMNIRACK)

**Métricas del sensor del rack:** temperatura (°C), humedad (%), consumo (kW),
estado de puerta (OPEN/CLOSED), bandera de alerta.

**Umbrales críticos (seed):**
| Rack | Temp aviso | Temp alerta | Consumo aviso | Consumo alerta |
|---|---|---|---|---|
| RACK-01 Core | 30°C | 35°C | 8.0 kW | 9.5 kW |
| RACK-02 Edge | 28°C | 33°C | 7.5 kW | 9.0 kW |
| RACK-03 Storage | 31°C | 36°C | 8.5 kW | 10.0 kW |
| RACK-04 GPU | 32°C | 37°C | 9.0 kW | 10.5 kW |

Humedad: aviso [20-75]%, alerta [10-85]%. Puerta abierta = alerta.

---

## 7. Repositorio / entorno

- Repo: `https://github.com/Stone3999/practicas` (raíz: `Smart Device Development`).
- Proyecto final: carpeta `omnirack/`.
- Flutter 3.44.0 / Dart 3.12.0 · Node v22.22.0 · ffmpeg (winget) · Windows.
- Secciones ya verificadas del historial: sin credenciales en ningún commit.
