# Documentación de Seguridad y Privacidad

Esta documentación describe las medidas de seguridad, cumplimiento normativo y políticas de privacidad del ecosistema OMNIRACK.

## Cumplimiento LFPDPPP

El proyecto se apega a la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP).

*   **Datos personales identificados**: En el contexto de este sistema, se recopilan IPs de servidores/dispositivos (art. 3 fr. V LFPDPPP) y tokens de acceso.
*   **Base legal**: Consentimiento informado del administrador del Data Center.
*   **Responsable**: Equipo OMNIRACK (Stone3999).

## Aviso de Privacidad

*   **Responsable del tratamiento**: Equipo OMNIRACK (Stone3999).
*   **Datos recabados**: Métricas de sensores (temperatura, humedad, consumo eléctrico, estado de puerta), tokens dinámicos de acceso, direcciones IPs de racks.
*   **Finalidad**: Monitoreo, gestión térmica en tiempo real y alertas del Data Center.
*   **Derechos ARCO**: Acceso, Rectificación, Cancelación y Oposición.
*   **Medio para ejercer derechos**: Enviar solicitud por correo electrónico al administrador del sistema.

## Plan de Retención y Eliminación de Datos

*   **Lecturas de sensores**: 30 días (configurable mediante la variable de entorno `DATA_RETENTION_DAYS`).
*   **Alertas**: 30 días.
*   **Tokens**: Tiempo de vida (TTL) de 5 minutos y de un solo uso.
*   **Eliminación automática**: Proceso cron que se ejecuta cada hora en el backend para limpiar registros antiguos.
*   **Eliminación manual**: Disponible mediante las rutas API:
    *   `POST /api/data/purge`
    *   `DELETE /api/racks/:id/data`

## Checklist de Seguridad PWA

- [x] Content Security Policy (CSP) configurado en el meta tag del HTML (`default-src 'self'`).
- [x] BroadcastChannel protegido con validación estricta de `event.origin`.
- [x] HTTPS recomendado obligatoriamente para despliegues en producción.
- [x] Ausencia total de credenciales en el código fuente y revisión del historial git.
- [x] Archivos `.env` correctamente añadidos a `.gitignore`.
- [x] Implementación de tokens dinámicos con TTL corto (5 mins) y de un solo uso.
