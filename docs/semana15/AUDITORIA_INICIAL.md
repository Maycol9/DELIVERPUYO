# Auditoría inicial — Prototipo 15

Fecha: 2026-09-22. `git status --short` y `git diff --stat` sin cambios antes de comenzar. No se encontraron archivos AGENTS.md dentro del repositorio. Este documento conserva el estado inicial; el cierre y los resultados actualizados están en DOCUMENTO_PROTOTIPO15.md.

## Estado encontrado antes de modificar

- Unitarias: autenticación y cierre de sesión (`auth_controller_test.dart`), serialización de pedidos, estados remotos, transporte Dio, configuración, caché, almacenamiento seguro y outbox. Existen pruebas de carreras de refresh y de aislamiento por cuenta.
- Widgets: componentes en `widget_test.dart`; rutas y login en `semana11_closure_test.dart`; formulario 422 y diagnóstico DEV en los tests de Semana 13. `semana15_catalog_test.dart` cubre loading, data, empty y error sobre la pantalla completa.
- Integración: `integration_test/public_backend_test.dart` y `integration_test/critical_order_test.dart`. Requieren backend/dispositivo o transporte controlado; el segundo contiene el único flujo crítico solicitado.
- E2E crítico solicitado: implementado como un único test de `critical_order_test.dart`; no se ejecutó contra backend real en este cierre.
- Dobles: ApiService falsos, MemorySession y HttpClientAdapter (`Adapter`) ya disponibles en tests; almacenamiento seguro y SharedPreferences simulados. No hace falta agregar una biblioteca de mocks.
- HTTP: pruebas existentes de 200, refresh concurrente 401, segundo 401 sin bucle, 422, conexión y timeouts, reintentos GET limitados y POST sin reintento automático.
- Validación: formulario y `OrderRepository` validan dirección, producto y cantidad entera de 1 a 50 antes de transporte o escritura outbox. La prueba cubre ocho entradas inválidas y tres válidas.
- Outbox: persiste un pedido por cuenta en almacenamiento seguro. `pending` permite reintento; `sending` conserva envíos ambiguos sin repetirlos porque el backend no ofrece idempotencia.
- Coverage: `flutter test --coverage --reporter expanded` generó `mobile/coverage/lcov.info`; se interpreta como mapa de líneas ejecutables, no como porcentaje global de ramas.
- Logging: ApiClient usa un callback que por defecto es debugPrint; solo DEV, rutas permitidas, sin cuerpos ni query, Authorization redactado. No tiene niveles estructurados.
- Monitoreo: no se encontraron SDKs o inicialización de Sentry/Crashlytics en lib ni dependencias. Requiere elegir servicio y configuración real; no se inventarán credenciales.
- CI: remoto GitHub presente y workflow local en `.github/workflows/flutter_tests.yml`, sin secretos ni despliegue automático.
- Omisiones: `semana13_prod_test.dart`, prueba `production logging remains off even when requested`, usa `skip: ApiConfig.environment != 'prod'`. Es condicional por entorno; debe ejecutarse también con `--dart-define=AMBIENTE=prod` y API_URL HTTPS. `pending` en outbox y `disabled` en widgets describen comportamiento, no pruebas desactivadas.

## Verificación posterior

- Suite con cobertura: 98 aprobadas y 1 omitida condicionalmente en DEV.
- Formato Dart: sin cambios.
- `flutter analyze`: sin incidencias.
- `flutter build apk --debug`: APK generado correctamente.

## Pendientes

Ejecutar el E2E en un dispositivo/emulador disponible, completar monitoreo con una cuenta/DSN real y medir rendimiento en dispositivo físico en modo profile. No tocar backend, Prisma, BD, .env ni contrato API; no hacer commit o push.
