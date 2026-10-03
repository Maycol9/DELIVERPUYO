# Cobertura como mapa

Comando final ejecutado desde `mobile`: `flutter test --coverage --test-randomize-ordering-seed=15 --reporter expanded`. También se ejecutó previamente `flutter test --coverage --reporter expanded`.
Archivo generado: `mobile/coverage/lcov.info`. La ejecución actual tuvo 98 aprobadas y 1 omitida condicionalmente en DEV, sin fallos. Las evidencias históricas conservan ejecuciones anteriores con 95 aprobadas; la omisión corresponde al entorno, no a una prueba desactivada permanentemente.

La ruta coverage está ignorada por Git en la configuración existente. Se conserva la copia final en `evidence/semana15/lcov-final.info` y la anterior en `evidence/semana15/lcov.info`, sin cambiar reglas de Git.

Valores reales leídos de registros DA del LCOV; son líneas ejecutables, no porcentaje de ramas ni de toda la aplicación. La E2E Android no forma parte de este LCOV.

| Archivo/área | Líneas recorridas / registradas |
|---|---:|
| auth/auth_controller.dart | 44 / 52 |
| services/api_client.dart | 99 / 122 |
| services/api_service.dart | 52 / 107 |
| orders/order_repository.dart | 62 / 66 |
| products/product_repository.dart | 20 / 24 |
| products/products_controller.dart | 29 / 35 |
| screens/products_screen.dart | 173 / 207 |
| screens/create_order_screen.dart | 127 / 154 |
| storage/session_storage.dart | 23 / 23 |
| services/app_logger.dart | 11 / 11 |
| services/order_native_service.dart | 0 / 37 |
| widgets/order_native_section.dart | 36 / 181 |

## Rama añadida después de inspeccionar cobertura

La primera ejecución con cobertura mostró `auth_controller.dart`, línea 38, `DA:38,0`: manejo de error en restore(). Se añadió `semana15_auth_test.dart` con un SessionStorage que falla al leer. Comprueba Unauthenticated, ausencia de sesión y aviso exacto sin exponer el error interno. La cobertura final registra `DA:38,1`; el archivo pasa de 40/52 a 44/52 líneas. No se presenta LCOV de líneas como cobertura completa de ramas.

## Límites y pendientes

Registro y perfil tienen escasa cobertura de pantalla (0/85 y 1/47). Cámara, permisos, GPS y recuperación nativa requieren pruebas adicionales; no se simula una validación física. Persisten caminos sin cubrir de recuperación de sesión válida, errores de registro, archivado/borrado de fotos y algunas carreras del transporte. No se amplió el alcance hacia Semana 14 por la restricción del encargo y por mantener las cinco prioridades originales.

El catálogo usa una pantalla real y un controlador de prueba que consume un fake repository. Verifica renderizado y reintento, no la lógica del controlador sustituido; las pruebas previas del repositorio y la E2E complementan ese límite. No se persigue un umbral arbitrario.
