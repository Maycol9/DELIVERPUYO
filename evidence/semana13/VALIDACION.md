# Validación final — Semana 13

## Herramientas
Flutter 3.44.4 estable; Dart 3.12.2. Dependencias seleccionadas por pub: Dio 5.11.1, flutter_secure_storage 11.1.0, shared_preferences 2.5.5, json_annotation 4.12.0, json_serializable 6.14.1, build_runner 2.15.1. No se actualizó Flutter ni Riverpod/go_router deliberadamente.

## Resultados ejecutados

| Comando / prueba | Resultado real |
|---|---|
| flutter pub get | Dependencias resueltas; http directo eliminado |
| dart run build_runner build --delete-conflicting-outputs | Exit 0; Product y OrderSummary generados; esta versión avisa que el flag fue eliminado y lo ignora |
| dart format . | Intentado; falló al enumerar una ruta transitoria de Gradle dentro de build/ |
| dart format lib test integration_test test_driver | Correcto, todas las fuentes Dart del proyecto formateadas |
| flutter analyze | No issues found!; salida en flutter-analyze.txt |
| flutter test --reporter expanded | 68 aprobadas, 1 omitida por estar condicionada a AMBIENTE=prod; salida en flutter-test.txt |
| flutter test test/semana13_prod_test.dart --dart-define=AMBIENTE=prod --dart-define=API_URL=https://example.invalid | 1 aprobada; transporte simulado, sin red productiva |
| flutter drive --driver=test_driver/integration_test.dart --target=integration_test/public_backend_test.dart -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:3000 --dart-define=AMBIENTE=dev | Prueba funcional Android aprobada; driver muestra +2 porque incluye tearDownAll, no son dos casos funcionales |
| GET http://localhost:3000/api/products | 200; success=true; 15 productos; backend-products.json |
| Flutter run normal con los tres dart-define solicitados | Compilación e instalación Android correctas, GET productos 200 |
| Offline y reconexión real en emulator-5554 | Caché visible con aviso; posterior GET 200 sin aviso. Red restaurada: avión=0, Wi-Fi=1, datos=1 |
| git diff --check | Sin errores de espacios; advertencias LF/CRLF de Windows no son errores del diff |

Total: 69 casos unitarios/widget únicos aprobados considerando ambas configuraciones (68 dev + 1 prod), más 1 caso funcional Android público. Las 28 pruebas previas siguen aprobadas; se añadieron 41 casos unitarios/widget de Semana 13. No sumar tearDownAll como prueba adicional.

La instalación inicial de plugins informó falta de soporte de symlinks para escritorio Windows; no se habilitó Developer Mode global. La compilación y ejecución Android sí finalizaron. Gradle instaló Android SDK Platform 35 requerido por dependencias; el dispositivo probado sigue siendo API 36.

## Límites

No se ejecutaron login exitoso real, creación, refresh real ni 422 protegido real por falta de login manual autorizado. El auxiliar propuesto para leer credenciales fue rechazado antes de ejecutarse. Refresh, outbox y 422 se verifican con fakes; la UI de error 422 también tiene prueba widget.

No se cambió backend, esquema, .env ni TTL. No se ejecutó seed ni se crearon pedidos, usuarios o direcciones. GET productos puede actualizar la caché Redis existente. La prueba de almacenamiento Android crea y borra únicamente una entrada local no secreta de verificación.
