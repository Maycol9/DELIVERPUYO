# Prototipo 15 — DeliverPuyo

Actualización: 2026-09-25. Sentry recibido según verificación comunicada por el propietario; rendimiento físico medido con DevTools en el TECNO KM4. Los resultados históricos conservados abajo no sustituyen la validación de cierre. No se declara listo para publicación.

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

Actualización de cierre 24/09/2026: flutter test y flutter test --coverage terminaron
con 132 aprobadas, 1 omitida y 0 fallos. LCOV actual: 1512 líneas ejecutadas de
2227 instrumentadas (67,89 %). Evidencia: evidence/semana15/lcov-cierre.info.
La cifra de 98 pruebas y los archivos *-final siguientes corresponden al 22/09,
no al estado actual. No se mide cobertura de ramas ni rendimiento con LCOV.

LCOV real en `mobile/coverage/lcov.info`, con copia final en `evidence/semana15/lcov-final.info`. Suite actual con cobertura: 98 aprobadas y una omisión condicional DEV; las evidencias históricas conservan ejecuciones anteriores con 95 aprobadas. COBERTURA.md explica áreas y límites. Se cubrió después de inspeccionar LCOV la rama restore() que falla al leer almacenamiento: `DA:38,0` pasó a `DA:38,1`. No se inventa cobertura de ramas ni se exige un porcentaje arbitrario.

## 10. Bugs/regresiones

Dos fallos reproducidos antes de cambiar producción: repositorio admitía borradores inválidos (ocho pruebas fallidas); selectores desbordaban en pantalla estrecha (regresión widget fallida y E2E). Correcciones mínimas en order_repository.dart y create_order_screen.dart, verificadas después. REGRESIONES.md y las evidencias conservan el antes. Ninguna prueba fue borrada o desactivada.

## 11. Logging

AppLogger incorpora JSON con niveles debug/info/warning/error y contexto enum. Se conecta al rechazo de borrador inválido. No acepta texto arbitrario ni datos personales. Se mantiene el logger HTTP redactado de Semana 13; no se afirma que todo el logging previo sea JSON. Los guardas DEV/PROD y redacción pasan. Detalle: LOGGING.md.

## 12. Monitoreo

Sentry Flutter 9.30.1 está integrado. El propietario confirma recepción real de StateError con traza, ambiente dev y versión 1.0.0 (1). La captura sanitizada del evento está archivada en `evidence/semana15/sentry-event-sanitized.png`; conserva StateError, `[REDACTED]` y la traza, sin barra de direcciones, ID del evento ni Trace ID. No se archiva DSN ni identificadores. Ver `evidence/semana15/sentry-verificacion.md` para distinguir recepción, privacidad local y evidencia visual.

## 13. Privacidad

Filtros locales implementados y probados: texto libre de mensajes/excepciones redactado; cuerpos y encabezados HTTP eliminados; breadcrumbs limitados a método, ruta permitida, estado y tipo de error. Identificador aleatorio por sesión, sin derivarlo de la cuenta; limpieza al salir. La inspección del contenido del evento remoto debe documentarse aparte de las pruebas locales.

## 14. Rendimiento

Medición real en TECNO KM4 físico, Android 15/API 35, Flutter 3.44.4, Dart 3.12.2 y DevTools 2.57.0. DevTools confirmó `Profile build`, Android arm64 y motor Impeller. El recorrido cubrió desplazamiento del catálogo, búsqueda, detalle, regreso y cambio de categoría. Se registraron 26 fotogramas, 59 FPS promedio, 0 fotogramas lentos, UI máxima 3,8 ms y Raster máxima 12,4 ms. Android reportó 60 Hz activos durante la medición, con modos 90/120 Hz disponibles; el presupuesto usado fue 16,67 ms. No se demostró un problema de fluidez y no se aplicó optimización innecesaria. Evidencia sanitizada: `evidence/semana15/performance-profile-2026-09-25.json`; exportación original conservada fuera del repositorio. Ver RENDIMIENTO.md para el análisis y las limitaciones.

## 15. CI

Workflow local `.github/workflows/flutter_tests.yml`: pub get, analyze, test --coverage y pruebas de logging PROD. Sin secretos ni despliegue. Flutter fijado a 3.44.4. No ejecutado en GitHub, porque no se hizo commit/push. Ver CI.md.

## 16. Checklist de publicación

CHECKLIST_PUBLICACION.md marca pruebas, estados UI, cobertura, medición física de rendimiento y captura visual sanitizada de Sentry aprobados. La corrección académica de fluidez no está demostrada porque la medición no encontró jank. Release aún usa firma debug; producción requiere firma adecuada y API_URL HTTPS con AMBIENTE=prod. Esa configuración se inspeccionó, no se modificó ni publicó.

## 17. Uso de IA

USO_IA.md enumera consultas, cambios y revisión de comportamiento. Solo se reportan comandos ejecutados y resultados observados. No se utilizaron agentes delegados.

## 18. Resultados

Resultados de cierre 24/09/2026: formato sin cambios (75 archivos, exit 0),
analyze sin incidencias (exit 0), test y test --coverage con 132 aprobadas,
1 omitida y 0 fallos (exit 0). Evidencias: format-cierre.txt, analyze-cierre.txt,
tests-cierre.txt, coverage-cierre.txt y lcov-cierre.info en evidence/semana15/.
No se repitió compilación ni E2E en esta sesión. La tabla siguiente es histórica.

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

1. Archivar evidencia sanitizada de Sentry y confirmar por escrito la revisión del mensaje redactado y ausencia de datos sensibles. No hace falta generar otro evento.
2. El requisito de corregir un problema de fluidez queda pendiente solo si la evaluación académica exige una regresión demostrada; esta medición no justificó cambios.
3. Antes de publicar: firma release y configuración productiva HTTPS. No se inventaron claves ni valores.
4. Ejecutar/revisar el workflow en GitHub cuando el propietario publique los cambios; no se realizó commit ni push.
