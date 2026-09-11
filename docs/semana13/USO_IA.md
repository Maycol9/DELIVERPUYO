# Registro de uso de IA

Herramienta: Codex / ChatGPT.
Uso: apoyo para revisión, implementación y pruebas del Prototipo 13.

| Consulta/tarea | Sugerencia técnica | Modificación aplicada / archivos | Verificación |
|---|---|---|---|
| Auditar proyecto existente | Inspeccionar antes de migrar | AUDITORIA_INICIAL.md; sin recrear Flutter | Git limpio inicial, lectura de lib/test/backend |
| Integrar varios recursos con auth | Un transporte Dio central | api_client.dart, api_service.dart | Configuración, header automático, rutas públicas y status en tests |
| Resolver expiración simultánea | Future compartido, retried y época de sesión | api_client.dart, auth_controller.dart | 401→refresh→retry; cinco concurrentes; anti-bucle; logout durante refresh |
| Persistir credenciales | Registro único en almacenamiento seguro | session_storage.dart, main.dart | Plugin Android: escritura/lectura real; fakes en pruebas unitarias |
| Serialización mínima | Generar dos proyecciones existentes | product.dart/g.dart, order.dart/g.dart | build_runner y pruebas Decimal/null/category |
| Evitar pérdida de catálogo | Caché primero, luego remoto | product_repository.dart, products_controller.dart | Repositorio con éxito/error y prueba Android real |
| Pedidos sin red | Guardar antes de enviar, no repetir resultados inciertos | order_repository.dart, orders_controller.dart, orders_screen.dart | Persistencia, aislamiento por usuario, 422 y no duplicación con fakes |
| Seguridad | HTTPS prod, logs sin cuerpos, HTTP solo debug | api_config.dart, manifiestos Android | Tests de ambientes y prod; revisión Git |
| Capturas reales | integration_test y adb | integration_test/public_backend_test.dart, test_driver/integration_test.dart | Catálogo público y caché reales; inventario de evidencia |

Las decisiones sobre tokens, refresh, reintentos, almacenamiento, HTTPS y logging se verificaron técnicamente contra el código del backend, la documentación oficial y las pruebas descritas. Esto no afirma una aprobación humana final: el propietario todavía debe revisar el diff.

Una propuesta de auxiliar local que leía credenciales y firmaba un token expirado fue rechazada por revisión automática de seguridad. No se ejecutó ni se creó el auxiliar. Se usó una alternativa pública sin secretos y se solicitó login manual directamente en el emulador. No se declara como realizada ninguna prueba autenticada que siga pendiente.
