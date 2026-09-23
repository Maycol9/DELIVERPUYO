# Privacidad de monitoreo

## Estado: IMPLEMENTADO — pendiente de DSN real y verificación manual

El filtro de privacidad `beforeSend` está implementado en `lib/services/sentry_privacy.dart`. La configuración de Sentry está lista en `lib/services/sentry_service.dart` y `lib/config/sentry_config.dart`. **No se envía ningún dato hasta que el usuario proporcione un DSN real**.

## Política implementada

- `sendDefaultPii = false` (por defecto y explícito).
- `beforeSend` serializa el evento a JSON, aplica sanitización recursiva y re-hidrata un `SentryEvent` limpio. Si la sanitización falla, el evento se descarta.
- Eliminación de contexto HTTP: headers sensibles, cookies, cuerpos, query, URLs con identificadores.
- Eliminación de usuario: email, nombre, IP, cédula, teléfono, coordenadas, dirección.
- Breadcrumbs: solo metadata segura (método, ruta sanitizada, status code, duración, tipo de error).
- NO se activa Session Replay, screenshots, grabación de pantalla, ni adjuntos.
- Usuario anónimo: SHA-256 de `AppUser.id`. Nunca email, nombre, cédula.

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
| `SentryEvent.request` | `url`, `method`, `headers`, `data`, `cookies` | Headers sensible → `[REDACTED]`; `data` recursivo |
| `SentryEvent.user` | `id`, `email`, `username`, `name`, `ipAddress`, `geo` | Email/name/IP eliminados; `id` = hash SHA-256 |
| `SentryEvent.breadcrumbs` | `message`, `data`, `category` | Recursivo sobre `data`; patrones Bearer/JWT/email en `message` |
| `SentryEvent.extra` | `Map<String, dynamic>` | Recursivo: keys sensibles → `[REDACTED]` |
| `SentryEvent.tags` | `Map<String, String>` | Keys sensibles → `[REDACTED]` |
| `SentryEvent.contexts` | `device`, `app`, `os`, `custom` | Recursivo sobre todos los valores |
| `SentryEvent.message` | `message`, `format`, `params` | Patrones Bearer/JWT/email → `[REDACTED]` |

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
