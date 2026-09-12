# Resultado final — Prototipo 13 DeliverPuyo

Actualizado 2026-09-11 (America/Guayaquil). Creación real y 422 real comprobados; diagnóstico DEV y corrección del middleware probados. Se está completando correlación visual de expiración natural.

## Dirección y creación

Consulta PostgreSQL de solo lectura: admin sin direcciones, cuenta CLIENT de prueba con una dirección. El usuario ingresó manualmente a esa cuenta. Se usó Casa - Puyo, Pastaza; no se creó fixture ni dirección.

Se envió una sola vez el formulario real con Producto 1 y cantidad 1. POST /api/orders respondió 201. Conteo de pedidos antes 27, después 28. ID d6528596-e558-40b9-9f5f-7ac184f82d64, estado PENDING, total $4,00, creado 2026-09-12 03:40:56.033 UTC (11 de septiembre 22:40:56, Ecuador).

Capturas 03/04; log cierre-final-http.txt; consulta selectiva pedido-creado-verificacion.txt. Un pedido y su ítem creados por la acción automatizada; stock disminuyó en una unidad. Una consulta posterior detectó otro pedido 7a7f3c83-0e26-4a59-b610-9cac27bfe170 a las 03:48:49 UTC, fuera del envío realizado por el agente, sin origen confirmado. Total global pasó después a 29; no se atribuye ese registro al diagnóstico ni se oculta el aumento. Ningún usuario/dirección creado. No repetir el pedido para obtener nuevas evidencias.

## 422 y fallo descubierto

El esquema real exige cantidad entera 1–50. La UI ya aplica esa regla. Se añadió el diagnóstico DEV autorizado: envía una copia con cantidad 0 mediante OrderRepository/ApiService y sesión interna normal, sin leerla por herramientas. No toca outbox ni sustituye pendientes. Conserva los valores válidos del formulario y asocia el error real items a Cantidad, único campo alterado en el diagnóstico. Fuera de DEV/no release no aparece y el repositorio rechaza ejecutarlo.

Primer ensayo: POST /api/orders 401 → refresh 200 → retry POST 401; anti-bucle cerró sesión. NO fue un 422 exitoso. Causa: middleware/auth.ts capturaba errores de await next() y los convertía en 401. Se movió next() fuera del catch de verificación. No se cambió el esquema, TTL ni secretos. Siete pruebas del middleware preservan 422/403/409/500 y conservan 401 para autenticación fallida.

Evidencia de incidencia: incidencia-validacion-401.txt. Login manual posterior observado en logs a las 03:48:40 UTC. Tras la corrección: POST /api/orders 422 a las 03:56:21 (hora Android), con el mensaje real “Too small: expected number to be >0” junto a Cantidad. Formulario conserva Casa, Producto 1 y cantidad 1. Capturas 07/08 y 422-http-real.txt. Conteo antes/después de este diagnóstico: 29/29; cero pedidos creados por el 422.

## Refresh

Flujo real previo: GET /api/addresses y /api/orders 401 → una llamada POST /api/auth/refresh 200 → reintentos GET 200 → sesión conservada. Log cierre-http-redactado.txt, captura 06 histórica. TTL operativo leído por nombres permitidos: acceso 15 minutos, refresh 7 días; no modificado.

05 fue actualizada con Pedidos y GET /api/orders 200 a las 03:57:27 tras el login manual de las 03:48:40. Se espera expiración natural después de las 04:03:40 para actualizar 06 y registrar un mismo flujo. El ensayo inválido que cerró sesión se documenta por separado; no prueba transparencia exitosa.

Anti-bucle y cinco solicitudes concurrentes con una renovación cubiertos por tests. No se extrajeron ni imprimieron valores de sesión.

## Offline, modelos y datos

15 productos desde caché, reconexión GET 200, capturas 09/10/11 conservadas. Product y OrderSummary tienen serialización generada y conversiones/null documentados. Remoto/local/repositorio implementados; UI sin HTTP directo. Outbox probado con fakes, sin un segundo pedido real para demostrarlo.

## Pruebas

- dart format lib test: 52 archivos, 0 cambios al final.
- flutter analyze: sin problemas.
- DEV: 70 aprobadas y 1 omitida condicionada a PROD.
- PROD: 3 aprobadas (logging, diagnóstico oculto/bloqueado y ausencia de envío/outbox).
- Total Flutter: 73 ejecuciones aprobadas entre ambientes; dos casos se ejecutan en ambos ambientes, no son 73 casos únicos.
- Backend: 7 pruebas de regresión aprobadas; npm run typecheck correcto.
- Android: creación y UI reales comprobadas mediante adb/hot reload; integración automatizada pública anterior aprobada (1 caso), no reejecutada porque reinstala/reinicia y contradice conservar la app.

Logs definitivos: final-flutter-analyze.txt, final-flutter-test.txt, final-flutter-prod.txt, final-backend-auth-test.txt.

## Seguridad y cambios

Diagnóstico solo DEV/no release, HTTPS PROD, logging PROD desactivado; tests aprobados. .env sin modificar/versionar, no secretos usados como dart-define. Herramientas no leyeron secure storage ni tokens. Una búsqueda previa del seed expuso accidentalmente contraseñas de prueba; no se reproducen en evidencia nueva ni se utilizaron. No se afirma ausencia de exposición en toda la conversación.

Cambios permanentes: alcance del catch en middleware/auth.ts; diagnóstico DEV en repositorio/controller/formulario; tests y documentación. Sin cambios de esquema, seed, migraciones, secretos ni configuración de TTL. El refresh real rota registros de sesión y GET puede actualizar Redis.

## Estado de cierre

Dirección resuelta y un único pedido creado. 422 real y capturas 07/08 completados; correlación visual de refresh en curso. Rúbrica aún no completa. No hubo git add, commit ni push.
