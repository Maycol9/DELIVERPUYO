# Inventario de evidencias — Semana 13

Capturas PNG reales, inspeccionadas visualmente. No contienen contraseñas ni tokens.

| Archivo solicitado | Estado | Qué demuestra |
|---|---|---|
| 01_login.png | Disponible | Formulario de login real; NO demuestra login exitoso |
| 02_productos_backend_real.png | Disponible | Productos de GET /api/products real en Android |
| 03_creacion_registro.png | Pendiente | Requiere login manual; no se creó un registro |
| 04_registro_creado.png | Pendiente | No existe pedido de demostración creado en esta ejecución |
| 05_refresh_token_antes.png | Pendiente | Expiración real aún no provocada |
| 06_refresh_token_exitoso.png | Pendiente | Refresh probado con fake; todavía falta evidencia autenticada real |
| 07_error_422.png | Pendiente | Falta petición protegida real inválida |
| 08_error_campo_422.png | Pendiente | Test widget verifica asociación por campo, pero falta captura del backend real |
| 09_online_catalogo.png | Disponible | Catálogo real y 15 productos |
| 10_offline_catalogo_cache.png | Disponible | Modo avión, producto guardado y aviso de datos desactualizados |
| 11_sincronizacion_reconexion.png | Disponible | Red restaurada, catálogo actualizado y aviso offline retirado; NO demuestra outbox real |
| 12_seguridad_configuracion.png | Disponible | Panel de prueba Android después de verificar escritura/lectura segura y rechazo de HTTP en prod |

01/02/09/12: capturadas con IntegrationTestWidgetsFlutterBinding.takeScreenshot y driver local. 10/11: adb screencap del emulador. La captura 12 corresponde a un informe de prueba, no a una pantalla nueva del producto.

Offline real: GET /api/products registró cuatro connectionError (intento original + tres reintentos). Los datos siguieron visibles. Tras restaurar modo avión=0, wifi_on=1, mobile_data=1, GET /api/products respondió 200 y desapareció el aviso. No se apagó la red del equipo anfitrión.

Pruebas de refresh/concurrencia, outbox y 422 emplean fakes cuando así lo indican los tests. No equivalen a las seis capturas autenticadas pendientes. No se sustituyeron esas imágenes por capturas de otras semanas ni por imágenes generadas.
