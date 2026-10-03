# Índice de evidencias — Semana 13

Actualizado 2026-09-11. Las imágenes existentes se conservan con su fecha real; no se fabrican imágenes ni se atribuye una captura a otro flujo. Logs limitados a método/ruta/status/tiempo complementan las capturas.

| N.º | Archivo | Qué demuestra | Estado | Criterio de rúbrica |
|---|---|---|---|---|
| 01 | 01_login.png | Formulario vacío de login; no muestra contraseña | Válido, histórico | Autenticación |
| 02 | 02_productos_backend_real.png | Catálogo real del backend | Válido, histórico | Cliente y datos |
| 03 | 03_creacion_registro.png | Dirección existente, Producto 1, cantidad 1 antes del único envío | Válido, actual | Datos y serialización |
| 04 | 04_registro_creado.png | Pedido d6528596 visible, total $4,00; log POST 201 | Válido, actual | Datos y serialización |
| 05 | 05_refresh_token_antes.png | Pedidos protegido, GET 200 a las 03:57:27 después del login manual | Válido actual; esperando expiración natural para correlacionar 06 | Autenticación y renovación |
| 06 | 06_refresh_token_exitoso.png | Pantalla protegida posterior al flujo GET 401→refresh→GET 200 previo | Válido con cierre-http-redactado.txt; histórico | Renovación |
| 07 | 07_error_422.png | Respuesta 422 real corregida, log 03:56:21 | Válido, actual | Errores |
| 08 | 08_error_campo_422.png | Mensaje real junto a Cantidad conservando formulario | Válido, actual | Errores |
| 09 | 09_online_catalogo.png | 15 productos | Válido, histórico | Datos |
| 10 | 10_offline_catalogo_cache.png | Avión, producto en caché y aviso offline | Válido, histórico | Datos y errores |
| 11 | 11_sincronizacion_reconexion.png | Catálogo actualizado tras reconexión, no outbox real | Válido, histórico | Datos y reintentos |
| 12 | 12_seguridad_configuracion.png | Informe Android de almacenamiento y HTTPS, sin valores de sesión | Válido, histórico; tests PROD actuales complementan | Seguridad |

## Evidencia técnica complementaria

- cierre-final-http.txt: único POST de creación 201.
- pedido-creado-verificacion.txt: conteo 28 e ID/producto/cantidad por consulta selectiva. Antes del envío: 27 pedidos.
- incidencia-validacion-401.txt: ensayo inválido antes de corregir middleware; NO se presenta como 422 ni como expiración natural.
- cierre-http-redactado.txt: renovación real previa de solicitudes GET, una renovación y reintentos 200.
- final-flutter-analyze.txt, final-flutter-test.txt y final-flutter-prod.txt: análisis y suites actuales.
- final-backend-auth-test.txt: siete pruebas de preservación de errores/autenticación.

No se eliminaron capturas históricas adicionales ni logs de pruebas anteriores. El conjunto solicitado tiene doce PNG disponibles; falta actualizar 06 para correlacionarlo con la captura 05 actual. Los PNG disponibles se decodificaron y revisaron sin valores de autenticación.
