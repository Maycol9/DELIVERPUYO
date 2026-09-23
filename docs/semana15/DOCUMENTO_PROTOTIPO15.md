# Prototipo 15 — DeliverPuyo

Fecha: 2026-09-22. Estado: validación automatizada aprobada; monitoreo y rendimiento físico pendientes por las pausas explícitas del encargo. No se declara listo para publicación.

## 1. Objetivo

Probar y depurar el proyecto real para la Semana 15 manteniendo Flutter, Riverpod, go_router, Dio y persistencia existentes. Flutter local 3.44.4, Dart 3.12.2, app 1.0.0+1. Auditoría inicial con Git limpio.

## 2. Inventario de riesgos

INVENTARIO_RIESGOS.md relaciona probabilidad, impacto, prioridad, prueba y motivo. Los riesgos son bloqueo de acceso, credenciales inválidas, pedidos inválidos/perdidos, catálogo incorrecto y ruptura del recorrido principal.

## 3. Priorización

Probabilidad e impacto estimados de 1 a 3, multiplicados para ordenar. Pedidos inválidos y pérdida offline: prioridad 9; acceso y flujo principal: 6; catálogo: 4. Son estimaciones de riesgo, no frecuencias observadas.

## 4. Cinco pruebas seleccionadas

| Prioridad del foro | Tipo y comportamiento comprobado | Resultado real |
|---|---|---|
| 1. Inicio de sesión | Unitarias con fake: credenciales válidas/inválidas, Authenticated, AuthFailure, Unauthenticated inicial/logout y error de restauración | Aprobadas |
| 2. Validación de pedidos | Unitarias: 1/2/50 válidos; cero, negativa, fracción, exceso y obligatorios inválidos; sin GET/POST ni escritura inválida | 11 casos aprobados |
| 3. Pedido offline/outbox | Dobles HTTP de conexión/timeout; persistencia íntegra, recreación, reintento único y POST ambiguo sin replay | 3 casos nuevos y suite previa aprobados |
| 4. Estados del catálogo | Pantalla real con fake repository y controlador de prueba: loading, data, empty, error y reintento | 4 casos aprobados |
| 5. Único E2E crítico | integration_test Android: abrir, login, catálogo, seleccionar, crear pedido y mostrarlo | 1 caso aprobado |

No se reemplazaron estas cinco pruebas por otras. Se conservó la integración previa de API pública, que no es otro flujo E2E crítico añadido y no se ejecutó contra el backend en esta sesión.

## 5. Pruebas unitarias

Se reutiliza auth_controller_test.dart y los dobles existentes. Se añade la rama de fallo al recuperar sesión. La validación nueva usa el repositorio productivo y un ApiService que registra llamadas. El outbox usa ApiService/ApiClient reales con HttpClientAdapter y almacenamiento seguro simulado; compara también metadatos opcionales sintéticos de foto/ubicación, sin afirmar pruebas físicas.

## 6. Prueba de interfaz

semana15_catalog_test.dart comprueba la pantalla ProductsScreen, no solo StateView. El controlador de prueba traduce snapshots del fake repository para aislar renderizado: no debe confundirse con prueba del controlador productivo. Las pruebas previas y la E2E cubren la integración con este último.

Se conservó el test existente de asociación de errores 422 y retención del borrador. Se añadieron cantidad vacía/cero/negativa sin envío y regresión de selectores en 320 px: cuatro casos nuevos del formulario aprobados.

## 7. E2E

`mobile/integration_test/critical_order_test.dart` contiene un único testWidgets. Ejecutado mediante `flutter test integration_test/critical_order_test.dart -d emulator-5554 --reporter expanded`: `+1: All tests passed!`, exit 0. Evidencia: `evidence/semana15/e2e.txt`.

Usa DeliverPuyoApp, router, formularios, controladores, repositorios y Dio reales. Reemplaza únicamente servicios externos mediante transporte HTTP controlado y almacenamiento aislado de pruebas. Selecciona controles desde UI, valida el cuerpo del POST, envío único, ruta final, pedido visible y borrador limpio. El arranque reproduce restauración/montaje de la app con ProviderContainer de prueba, sin invocar main() con dependencias reales.

Decisión: backend controlado para no depender de Internet, usuarios, stock o BD real. No prueba disponibilidad del servidor, plugins físicos ni rendimiento. No usa flutter_driver. Se ejecutó en Android API 36 emulado; tras desconexiones se usó arranque sin snapshots/renderizado software. La E2E detectó una regresión real de layout que fue corregida.

## 8. Dobles de prueba

Se reutilizan Adapter, MemorySession, makeClient, jsonBody y FormApi de Semana 13. HTTP 200, 401 con una renovación y retry, segundo 401 sin bucle, 422 por campo y timeout pasan en la suite. GET tiene reintentos limitados; POST ambiguo no se reenvía porque no existe idempotencia del backend. No se cambió el contrato para el test.

## 9. Cobertura

LCOV real en `mobile/coverage/lcov.info`, con copia final en `evidence/semana15/lcov-final.info`. Suite actual con cobertura: 98 aprobadas y una omisión condicional DEV; las evidencias históricas conservan ejecuciones anteriores con 95 aprobadas. COBERTURA.md explica áreas y límites. Se cubrió después de inspeccionar LCOV la rama restore() que falla al leer almacenamiento: `DA:38,0` pasó a `DA:38,1`. No se inventa cobertura de ramas ni se exige un porcentaje arbitrario.

## 10. Bugs/regresiones

Dos fallos reproducidos antes de cambiar producción: repositorio admitía borradores inválidos (ocho pruebas fallidas); selectores desbordaban en pantalla estrecha (regresión widget fallida y E2E). Correcciones mínimas en order_repository.dart y create_order_screen.dart, verificadas después. REGRESIONES.md y las evidencias conservan el antes. Ninguna prueba fue borrada o desactivada.

## 11. Logging

AppLogger incorpora JSON con niveles debug/info/warning/error y contexto enum. Se conecta al rechazo de borrador inválido. No acepta texto arbitrario ni datos personales. Se mantiene el logger HTTP redactado de Semana 13; no se afirma que todo el logging previo sea JSON. Los guardas DEV/PROD y redacción pasan. Detalle: LOGGING.md.

## 12. Monitoreo

No existía SDK. Sentry es la opción elegida para continuar por su SDK Flutter y [plan Developer gratuito](https://sentry.io/pricing/). La configuración requiere cuenta/proyecto y DSN real según el [SDK oficial](https://pub.dev/packages/sentry_flutter). Se respeta la pausa solicitada: no instalado/configurado, sin evento remoto enviado ni DSN falso. Ver MONITOREO.md.

## 13. Privacidad

Logs locales verificados. PRIVACIDAD_MONITOREO.md establece filtros que todavía deben implementarse y probarse antes de habilitar el SDK remoto. No hay un identificador anónimo dedicado verificado; se propone omitir identidad. No se afirma que filtros remotos ya funcionen.

## 14. Rendimiento

No medido. Pendiente dispositivo físico en profile: arranque, fluidez, frames lentos, UI y raster. RENDIMIENTO.md deja el procedimiento. No se optimizó a ciegas ni se confunden tiempos de tests/build con rendimiento. La corrección de overflow es funcional, no una mejora medida de fluidez.

## 15. CI

Workflow local `.github/workflows/flutter_tests.yml`: pub get, analyze, test --coverage y pruebas de logging PROD. Sin secretos ni despliegue. Flutter fijado a 3.44.4. No ejecutado en GitHub, porque no se hizo commit/push. Ver CI.md.

## 16. Checklist de publicación

CHECKLIST_PUBLICACION.md marca pruebas, estados UI, cobertura y compilación aprobados. Monitoreo/performance siguen pendientes. Release aún usa firma debug; producción requiere firma adecuada y API_URL HTTPS con AMBIENTE=prod. Esa configuración se inspeccionó, no se modificó ni publicó.

## 17. Uso de IA

USO_IA.md enumera consultas, cambios y revisión de comportamiento. Solo se reportan comandos ejecutados y resultados observados. No se utilizaron agentes delegados.

## 18. Resultados

| Comando desde mobile | Resultado final |
|---|---|
| dart format lib test integration_test | Completado; solo archivos nuevos reformateados |
| flutter analyze | Sin incidencias, exit 0 |
| flutter test --coverage --reporter expanded | 98 aprobadas, 1 omitida por entorno, LCOV generado, exit 0 |
| flutter test test/semana13_prod_test.dart test/semana15_logging_test.dart --dart-define=AMBIENTE=prod --dart-define=API_URL=https://example.invalid | 3 aprobadas, 0 omitidas, exit 0 |
| flutter test integration_test/critical_order_test.dart -d emulator-5554 --reporter expanded | 1 E2E aprobada, exit 0 |
| flutter build apk --debug | APK normal final compilado, exit 0 |

La prueba condicional exacta es `production logging remains off even when requested` de semana13_prod_test.dart. Su skip solo se aplica fuera de PROD; fue ejecutada explícitamente en su entorno. Las coincidencias pending/disabled restantes describen datos o estados, no omisiones.

No se hizo commit/push. No se cambió backend, Prisma, BD, .env, dependencias ni contrato API. Un rechazo transitorio de ejecución por límite de uso se resolvió tras la indicación del usuario de continuar; no es un bloqueo pendiente.

## 19. Pendientes manuales reales

1. **ACCIÓN MANUAL REQUERIDA — MONITOREO:** cuenta/proyecto y DSN real para integrar Sentry; luego filtros, fallo controlado, stack trace y versión verificados en el panel.
2. **ACCIÓN MANUAL REQUERIDA — PRUEBA DE RENDIMIENTO EN DISPOSITIVO FÍSICO:** ejecutar profile, medir, identificar problema real y volver a medir tras corregirlo.
3. Antes de publicar: firma release y configuración productiva HTTPS. No se inventaron claves ni valores.
4. Ejecutar/revisar el workflow en GitHub cuando el propietario publique los cambios; no se realizó commit ni push.
