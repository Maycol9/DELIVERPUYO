# Privacidad de monitoreo

## Estado: IMPLEMENTADO — recepción confirmada por el propietario

El filtro `beforeSend` está implementado. El propietario confirmó el 24/09/2026
la recepción remota de StateError con traza, ambiente dev y versión 1.0.0 (1).
La captura sanitizada archivada fue revisada visualmente: no muestra la barra de
direcciones, el ID del evento ni el Trace ID, y conserva solo los datos técnicos
necesarios visibles.
No se almacena el DSN. Las pruebas locales no sustituyen esa revisión remota.

## Política implementada

- `sendDefaultPii = false` (por defecto y explícito).
- `beforeSend` serializa el evento a JSON, aplica sanitización recursiva y re-hidrata un `SentryEvent` limpio. Si la sanitización falla, el evento se descarta.
- Eliminación de contexto HTTP: headers sensibles, cookies, cuerpos, query, URLs con identificadores.
- Eliminación de usuario: email, nombre, IP, cédula, teléfono, coordenadas, dirección.
- Breadcrumbs HTTP: solo método, ruta sanitizada, estado y tipo de error; sin duración ni cuerpos. Otros breadcrumbs: texto redactado y datos eliminados.
- NO se activa Session Replay, screenshots, grabación de pantalla, ni adjuntos.
- Usuario anónimo: identificador aleatorio por sesión, no derivado de AppUser.id; se limpia al cerrar o invalidar sesión. Sentry se inicializa antes de restaurar la sesión.
- Mensajes y valores de excepciones: texto libre sustituido por [REDACTED]; tipo y traza conservados, sin variables ni contexto de código de los frames.

## Tabla de datos

| Dato | ¿Se envía? | Tratamiento |
|---|---|---|
| Authorization header | NO | `[REDACTED]` por `beforeSend` |
| Access token | NO | `[REDACTED]` — clave `access_token` |
| Refresh token | NO | `[REDACTED]` — clave `refresh_token` |
| Password | NO | `[REDACTED]` — clave `password` |
| Email | NO | `[REDACTED]` — clave `email` + patrón regex |
| Cédula / documento | NO | `[REDACTED]` — claves `cedula`, `documento`, `document` |
| Dirección | NO | `[REDACTED]` — claves `direccion`, `address` |
| Coordenadas (lat/long) | NO | `[REDACTED]` — claves `latitude`, `longitude`, `coordinates` |
| Teléfono | NO | `[REDACTED]` — claves `phone`, `telefono` |
| HTTP method | SÍ | Conservado en breadcrumbs y request |
| Status code | SÍ | Conservado en breadcrumbs |
| Tipo de error | SÍ | Conservado en breadcrumbs y eventos |
| Versión app (release) | SÍ | Formato `deliverpuyo_mobile@<version>+<build>` |
| Environment | SÍ | `dev` / `test` / `staging` / `prod` |
| Stack trace | SÍ | Conservado (no PII, rutas locales) |
| URI interna | SÍ | Rutas sanitizadas por allowlist |

## Superficies de captura sanitizadas

| Superficie | Campos revisados | Sanitización |
|---|---|---|
| `SentryEvent.request` | `url`, `method`, `headers`, `data`, `cookies` | Solo método permitido y ruta sanitizada; resto eliminado |
| `SentryEvent.user` | `id`, `email`, `username`, `name`, `ipAddress`, `geo` | Email/name/IP eliminados; integración asigna ID aleatorio |
| `SentryEvent.breadcrumbs` | `message`, `data`, `category` | HTTP limitado a vocabulario cerrado; texto libre y datos de otros breadcrumbs eliminados |
| `SentryEvent.extra` | `Map<String, dynamic>` | Recursivo: keys sensibles → `[REDACTED]` |
| `SentryEvent.tags` | `Map<String, String>` | Keys sensibles → `[REDACTED]` |
| `SentryEvent.contexts` | `device`, `app`, `os`, `custom` | Recursivo sobre todos los valores |
| `SentryEvent.message` | `message`, `format`, `params` | Sustituido por mensaje [REDACTED], sin parámetros |

## Pruebas de privacidad

| Test | Resultado esperado |
|---|---|
| Authorization → `[REDACTED]` | ✓ |
| accessToken → `[REDACTED]` | ✓ |
| refreshToken → `[REDACTED]` | ✓ |
| password → `[REDACTED]` | ✓ |
| email → `[REDACTED]` | ✓ |
| latitude/longitude → `[REDACTED]` | ✓ |
| HTTP method + status conservados | ✓ |
| Usuario sin email ni documento | ✓ |
| Test crash solo en entorno permitido | ✓ |
