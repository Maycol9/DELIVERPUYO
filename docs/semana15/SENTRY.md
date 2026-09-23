# Sentry — DeliverPuyo (Semana 15)

## 1. Objetivo

Configurar monitoreo de fallos con Sentry de forma segura, compatible con la Semana 15, cumpliendo con los requisitos de privacidad establecidos. Capturar excepciones no controladas con stack trace y versión de app, sin exponer datos sensibles.

## 2. Servicio utilizado

**Sentry** (plan gratuito Developer). Paquete Dart oficial: `sentry_flutter ^9.30.1`. No se utiliza Crashlytics ni Firebase. Ver [auditoría de reproducibilidad](SENTRY_REPRODUCIBLE.md).

## 3. Motivo de elección

- SDK oficial y maduro para Flutter.
- Captura errores Dart, Flutter framework, y crashes nativos (Android/iOS).
- `beforeSend` permite filtrado granular de privacidad.
- No exige integración con Firebase.
- Plan gratuito disponible.

## 4. Configuración

### Instalación

```yaml
dependencies:
  sentry_flutter: ^9.30.1
  crypto: ^3.0.7
```

### Variables de entorno (dart-define)

| Variable | Descripción | Valor por defecto |
|---|---|---|
| `SENTRY_DSN` | DSN del proyecto Sentry | `''` (vacío = Sentry deshabilitado) |
| `SENTRY_TEST_MODE` | Activa fallo de prueba controlado | `false` |
| `AMBIENTE` | Ambiente (heredado de `ApiConfig`) | `dev` |
| `FLUTTER_BUILD_NAME` | Nombre de versión (auto) | `0.0.0` |
| `FLUTTER_BUILD_NUMBER` | Número de build (auto) | `0` |

### Opciones del SDK

En `SentryService.configureOptions` (`lib/services/sentry_service.dart:21`):

```dart
options
  ..dsn = SentryConfig.dsn
  ..environment = SentryConfig.environment
  ..release = SentryConfig.release
  ..sendDefaultPii = false
  ..beforeSend = SentryPrivacy.beforeSend
  ..enableLogs = false
  ..enableMetrics = false
  ..beforeSendLog = ((_) => null)
  ..beforeSendMetric = ((_) => null)
  ..enableAutoPerformanceTracing = false
  ..enableUserInteractionBreadcrumbs = false
  ..enableAutoNativeBreadcrumbs = false
  ..enableAppLifecycleBreadcrumbs = false
  ..attachScreenshot = false
  ..reportSilentFlutterErrors = false
  ..anrEnabled = false
  ..maxCacheItems = 10;
```

## 5. Uso de dart-define

El DSN **nunca** se escribe en código. Se pasa en tiempo de ejecución:

### PowerShell (Windows)

```powershell
flutter run `
  --dart-define=SENTRY_DSN=<DSN_REAL> `
  --dart-define=AMBIENTE=dev `
  --dart-define=SENTRY_TEST_MODE=true
```

### macOS / Linux (bash)

```bash
flutter run \
  --dart-define=SENTRY_DSN=<DSN_REAL> \
  --dart-define=AMBIENTE=dev \
  --dart-define=SENTRY_TEST_MODE=true
```

## 6. Datos filtrados

El filtro `beforeSend` (`lib/services/sentry_privacy.dart:93`) serializa el evento a JSON, aplica sanitización recursiva y re-hidrata un `SentryEvent` limpio. Si la sanitización falla, el evento se descarta (returns `null`).

### Claves sensibles redactadas (case-insensitive, con/sin underscore)

`authorization`, `access_token`, `refresh_token`, `password`, `email`, `cedula`, `documento`, `direccion`, `address`, `phone`, `telefono`, `latitude`, `longitude`, `coordinates`, `cookies`, `ip_address`, `session`, `user_id`

### Valores sensibles redactados (patrones)

- `Bearer <token>` → `[REDACTED]`
- JWT (`eyJ...`) → `[REDACTED]`
- Emails → `[REDACTED]`

### Campos sanitizados

| Campo | Tratamiento |
|---|---|
| `request.headers` | Todas las headers con keys sensibles → `[REDACTED]` |
| `request.data` | Recursivamente sanitizado |
| `user.email` / `user.name` / `user.username` / `user.ipAddress` | Eliminados (nunca enviados) |
| `breadcrumbs.data` / `breadcrumbs.message` | Recursivamente sanitizado |
| `extra` | Recursivamente sanitizado |
| `tags` | Keys sensibles → `[REDACTED]` |
| `contexts` | Recursivamente sanitizado |

## 7. Usuario anónimo

`SentryService.setAnonymousUser` (`lib/services/sentry_service.dart:63`):
- Usa SHA-256 de `AppUser.id` (no reversible).
- Nunca envía email, nombre, IP, cédula ni teléfono.
- Si no hay usuario autenticado, no configura usuario.

```
AppUser.id → sha256(id) → SentryUser(id: hash)
```

## 8. Logging

`AppLogger` (Semana 15) usa vocabulario cerrado. `SentryService` proporciona:
- `captureWarning(message)` — envía a Sentry con level `warning`.
- `captureError(exception, stackTrace)` — envía a Sentry con level `error`.

**NO** se envían logs de nivel `debug`. Solo `warning` y `error`.

## 9. Breadcrumbs

`SentryDioBreadcrumbInterceptor` (`lib/services/sentry_dio_interceptor.dart`) — opcional, captura solo metadata segura:
- HTTP method
- Ruta sanitizada (allowlist: `/api/auth/login`, `/api/products`, `/api/orders`, etc.)
- Status code
- Duración
- Tipo de error (en caso de fallo)

**NO** capta: headers, bodies, tokens, cookies, query strings.

Métodos de breadcrumb seguros:
```dart
SentryService.addBreadcrumb(message: 'Inicio de login', category: 'auth');
SentryService.addBreadcrumb(message: 'Carga catálogo', category: 'catalog');
SentryService.addBreadcrumb(message: 'Creación de pedido', category: 'orders');
SentryService.addBreadcrumb(message: 'Sincronización outbox', category: 'outbox');
```

## 10. Prueba de fallo

`SentryService.triggerTestCrash()` está activado **solo** cuando:
- `SENTRY_TEST_MODE=true` (dart-define)
- `AMBIENTE != prod`

Genera un `StateError('DeliverPuyo test crash — Semana 15')` controlado. No se ejecuta automáticamente. No hay botón visible en release.

## 11. Privacidad

Ver `PRIVACIDAD_MONITOREO.md` para la tabla completa de datos.

- `sendDefaultPii = false`
- Captura de pantalla deshabilitada (`attachScreenshot = false`)
- Session Replay **NO** configurado (no se activa)
- `enableNativeCrashHandling = true` captura crashes nativos (no PII, stack trace solo)

## 12. Limitaciones

- El DSN no se incluye en el código; debe proporcionarse en cada sesión.
- Sin DSN, Sentry está completamente deshabilitado (no bloquea la app).
- La verificación de eventos en el panel de Sentry requiere configuración manual.
- Debug symbols (`.symbols` / mapping files) para desofuscar stack traces en release deben subirse manualmente (fuera de alcance de esta fase).

## 13. Acción manual requerida

1. Crear cuenta en [sentry.io](https://sentry.io) (plan gratuito).
2. Crear proyecto Flutter.
3. Copiar el DSN.
4. No pegar el DSN en código ni en archivos versionados.
5. Ejecutar:

```powershell
flutter run `
  --dart-define=SENTRY_DSN=<DSN_REAL> `
  --dart-define=AMBIENTE=dev `
  --dart-define=SENTRY_TEST_MODE=true
```

> Por seguridad, no compartas aquí tu DSN. Úsalo únicamente en tu terminal local.
