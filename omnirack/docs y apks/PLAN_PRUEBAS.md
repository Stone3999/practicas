# Plan de Pruebas OMNIRACK

A continuación, se detallan los casos de prueba para validar el funcionamiento del ecosistema OMNIRACK.

| ID | Caso de Prueba | Descripción | Resultado Esperado | Estado |
|---|---|---|---|---|
| 1 | API Health Check | Solicitar `GET /api/health` al backend. | Retorna JSON `{ ok: true }` con código 200. | Pendiente |
| 2 | CRUD Racks | Realizar peticiones `POST`, `GET`, `PUT`, `DELETE` sobre `/api/racks` utilizando un token válido. | Las operaciones completan con éxito y la base de datos se actualiza. | Pendiente |
| 3 | Token Security | Intentar `PUT` sin token y con token. Reusar un token. | Sin token = 401. Con token = OK. Reuso de token = 401. | Pendiente |
| 4 | Sensor Data Flow | Enviar `POST /api/racks/:id/data` con datos simulados. | El backend registra la lectura en base de datos y evalúa los umbrales configurados. | Pendiente |
| 5 | Alertas por Umbral | Enviar métrica de temperatura ≥ 35°C al backend. | El backend genera y almacena una alerta de tipo "Temperatura crítica". | Pendiente |
| 6 | Puerta Abierta | Enviar métrica con estado de puerta `door=true`. | El backend genera y almacena una alerta de "Puerta del rack abierta". | Pendiente |
| 7 | SSE en Tiempo Real | Cliente web conectado a eventos SSE, y recibir nueva métrica o alerta. | El evento 'sensor' llega al frontend en < 2 segundos desde su creación. | Pendiente |
| 8 | BLE NOTIFY | Iniciar app en Wearable y en Teléfono. | Wearable genera datos, el teléfono los recibe (o usa simulación como fallback). | Pendiente |
| 9 | Teléfono → Backend | Verificar el reenvío de datos desde la app del teléfono. | Teléfono envía los datos BLE al backend vía `HTTP POST` exitosamente. | Pendiente |
| 10 | D-pad Navigation | Utilizar flechas direccionales del teclado/control remoto en la PWA (TV). | Las flechas mueven el foco visual entre los cards de racks, Enter selecciona. | Pendiente |
| 11 | Modo Offline | Apagar la red e intentar cargar la PWA en el navegador. | Service Worker sirve los recursos de la PWA desde la caché y muestra estado offline. | Pendiente |
| 12 | Desconexión BLE | Desconectar abruptamente el Wearable (apagar BT). | La app del teléfono maneja el error, no crashea, e intenta reconexión o notifica. | Pendiente |
| 13 | Sincronización End-to-End | Cambiar valor drástico en el wearable y observar PWA. | El cambio se refleja en la pantalla del Smart TV en < 2 segundos. | Pendiente |
| 14 | Ciclo de Vida de Datos | Crear datos, adelantar reloj 31 días y ejecutar limpieza. | Creación exitosa, el proceso purga elimina datos antiguos respetando el límite de 30 días. | Pendiente |

---

**Firma:** David Esteban Quevedo Ramos  
**Fecha:** Agosto 2026
