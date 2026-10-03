# Auditoría Sentry — DeliverPuyo (Semana 15)

Fecha: 2026-09-22. Flutter 3.44.4 / Dart 3.12.2 (stable).

## Estado encontrado antes de modificar

### Sentry existente

NO. No se encontró `sentry` ni `sentry_flutter` en `pubspec.yaml`, `pubspec.lock`, `lib/` ni `test/`. No hay DSN, inicialización, ni captura global.

### Crashlytics existente

NO. No se encontró ninguna dependencia de `firebase_crashlytics` ni configuración de Firebase en `pubspec.yaml`, `android/` ni `ios/`.

### Logging existente

Sí. `lib/services/app_logger.dart` define `AppLogger` con vocabulario cerrado (level, module, action, errorType). El callback de salida por defecto es `debugPrint`. La configuración de logging se controla con `dart-define=AMBIENTE` (default `dev`) y `kReleaseMode` en `ApiConfig.loggingEnabled` (`mobile/lib/config/api_config.dart:8`).

`ApiClient._log` (`mobile/lib/services/api_client.dart:215`) ya redacta `Authorization: Bearer [REDACTED]`, restringe a rutas permitidas y excluye query, body e identificadores de ruta. Funciona solo en DEV fuera de release.

### Captura global existente

NO. No se encontraron referencias a `FlutterError.onError`, `PlatformDispatcher.instance.onError`, `runZonedGuarded`, ni `Zone` en `lib/`. No hay captura global de errores no controlados.

### Fuente de configuración

- `ApiConfig.environment` lee `AMBIENTE` desde `dart-define` (`mobile/lib/config/api_config.dart:4`).
- `ApiConfig.baseUrl` lee `API_URL` desde `dart-define` (`mobile/lib/config/api_config.dart:25`).
- No existe archivo `.env` en `mobile/`. El `.env` en la raíz del repo (`NODE_ENV=development`) pertenece al backend y NO se toca.

### Dio interceptors

`mobile/lib/services/api_client.dart:34` registra un `InterceptorsWrapper` con:
- **onRequest**: valida origen de API, inyecta `Authorization: Bearer <accessToken>` solo cuando `extra['protected'] == true`, usa epoch anti-replay.
- **onResponse**: maneja refresh de 401, retry de 5xx.
- **onError**: retry limitado a GET.

Los tokens (`accessToken`, `refreshToken`) circulan por headers HTTP pero nunca se registran en logs. El `_log` solo guarda metadata: método, ruta sanitizada, código de estado, duración.

**Conclusión del intercepto HTTP**: el interceptor existente ya redacta `Authorization`. Sentry NO recibirá datos del cuerpo, query, o headers de la petición porque NO se usa `SentryDioInterceptor`. El `SentryService` proporciona `SentryDioBreadcrumbInterceptor` opcional que captura solo: método, ruta sanitizada, status code, duración, tipo de error.

### Datos sensibles encontrados

| Campo | Ubicación | Tratamiento actual |
|---|---|---|
| `accessToken` | `AuthSession.accessToken`, enviado como `Authorization: Bearer` | No registrado en logs; `_log` redacta |
| `refreshToken` | `AuthSession.refreshToken`, enviado en body `/api/auth/refresh` | No registrado en logs |
| `email` | `ApiService.login`/`register` body, `AppUser.email` | No registrado en logs HTTP |
| `password` | `ApiService.login`/`register` body | No registrado en logs HTTP |
| `cédula/documento` | `Address` model | No registrado en logs HTTP |
| `dirección` | `Address` model | No registrado en logs HTTP |
| `coordenadas` | `OrderLocation` (lat/long) | No registrado en logs HTTP |

Ningún dato sensible se expone actualmente en logs. El riesgo se mitiga con el filtro `beforeSend` de `SentryPrivacy`.

### Configuración de entorno

- Ambientes válidos (validados en `ApiConfig.validate`): `dev`, `test`, `staging`, `prod`.
- `dart-define=AMBIENTE=prod` + `API_URL=https://...` para producción.

## Cambios realizados

1. **Dependencia**: agregado `sentry_flutter: ^8.14.2` y `crypto: ^3.0.7` (transitivo → directo). Ambos verificados compatibles con Dart 3.12.2.
2. **DSN**: leído de `dart-define=SENTRY_DSN` vía `SentryConfig.dsn` (`lib/config/sentry_config.dart:14`). No hardcoded.
3. **Inicialización**: `SentryFlutter.init` con `appRunner`, preservando `ProviderScope` + `go_router` (`lib/services/sentry_service.dart:48`).
4. **Captura global**: `FlutterError.onError` configurado antes de `SentryFlutter.init`; `PlatformDispatcher.instance.onError` gestionado por el SDK (`OnErrorIntegration`).
5. **Privacidad**: `beforeSend` con sanitización recursiva vía JSON round-trip (`lib/services/sentry_privacy.dart:93`).
6. **Usuario**: SHA-256 de `AppUser.id`, sin email/nombre/IP (`lib/services/sentry_service.dart:63`).
7. **HTTP**: NO se usa `SentryDioInterceptor`; breadcrumbs opcionales con metadata segura (`lib/services/sentry_dio_interceptor.dart`).
8. **Logging**: `captureWarning` y `captureError` envían solo warning/error a Sentry; no debug ruidoso (`lib/services/sentry_service.dart:83`).
9. **Fallo controlado**: `triggerTestCrash()` solo con `SENTRY_TEST_MODE=true` y `AMBIENTE != prod` (`lib/services/sentry_service.dart:101`).
10. **Release**: `FLUTTER_BUILD_NAME` + `FLUTTER_BUILD_NUMBER` vía `String.fromEnvironment` (`lib/config/sentry_config.dart:45`).
11. **Tests**: 14 tests de sanitización + 7 tests de config (`mobile/test/semana15_sentry_*_test.dart`).
12. **Docs**: `SENTRY.md`, `PRIVACIDAD_MONITOREO.md` actualizado, `SENTRY_AUDITORIA.md`.
13. **Validación**: FASE 15 — `flutter analyze`, `flutter test`, `flutter build apk --debug` (solo local, sin DSN).

## Restricciones respetadas

- NO modificar backend, Prisma, BD, contrato API.
- NO tocar Semana 13 (`semana13_test.dart`, `semana13_prod_test.dart`, `semana13_*`).
- NO romper Semana 14 (logging estructurado, tests semana15_*).
- NO hacer commit ni push.
- NO inventar ni escribir DSN ficticio en código.
