# Guía del video — Prototipo 13

Duración sugerida: 6–8 minutos más la espera de expiración, que puede resumirse con un corte identificado. No grabar contraseñas, tokens, .env ni consola con cuerpos HTTP. Esta guía incluye pasos pendientes: no debe presentarse como evidencia de que ya se realizaron.

1. Presentar DeliverPuyo y el objetivo de integrar el backend.
2. Iniciar sesión manualmente; ocultar la contraseña y cualquier autocompletado.
3. Mostrar GET /api/products del backend local con success=true.
4. Mostrar los 15 productos reales en Android.
5. Completar un pedido válido de una unidad y enviarlo una sola vez. Si ya se creó el registro de demostración, mostrarlo sin duplicarlo.
6. Mostrar su identificador en Pedidos y anotar únicamente ID, total y fecha.
7. Abrir ApiClient y explicar la configuración única, 10 s de conexión y 15 s de recepción.
8. Explicar SecureSessionStorage; mostrar el código sin inspeccionar valores almacenados.
9. Para expiración real, esperar el TTL efectivo de expiresInSeconds. No modificar producción ni revelar secretos. El TTL predeterminado del código es 15 minutos; verificar el efectivo durante login autorizado.
10. Consultar Pedidos después de expirar y mostrar logs redactados: 401, POST /api/auth/refresh 200, GET /api/orders 200.
11. Mostrar que la pantalla permanece autenticada.
12. Provocar un 422 con un envío controlado inválido que no pueda crear registros, mediante una prueba de integración autorizada. La UI valida cantidades fuera de 1..50 antes de enviarlas: esa validación local NO es evidencia 422 del backend.
13. Mostrar el error real asociado a addressId/items en el formulario. Conservar el borrador; no cambiar reglas del servidor para fabricar el resultado.
14. Cargar catálogo, activar modo avión en el emulador y desactivar Wi-Fi si continúa encendido.
15. Actualizar; mostrar productos locales y aviso de posible desactualización.
16. Desactivar modo avión y restaurar Wi-Fi/datos.
17. Actualizar catálogo; explicar que pendientes no enviados se sincronizan al abrir/actualizar Pedidos. No crear otro pedido solo para repetir una evidencia ya obtenida.
18. Explicar HTTPS en prod, almacenamiento seguro, logs redactados y ausencia de secretos en dart-define.
19. Mostrar flutter analyze, flutter test y la prueba Android pública. Distinguir pruebas con fakes de las que usan el backend real.
20. Cerrar indicando lo implementado y cualquier evidencia autenticada aún pendiente.

## Comandos

Desde mobile:

```powershell
flutter run -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:3000 --dart-define=AMBIENTE=dev --dart-define=UI_DEMO_STATE=normal
flutter analyze
flutter test
flutter test test/semana13_prod_test.dart --dart-define=AMBIENTE=prod --dart-define=API_URL=https://example.invalid
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/public_backend_test.dart -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:3000 --dart-define=AMBIENTE=dev
```

La prueba prod utiliza un interceptor de respuesta simulado y no contacta example.invalid ni servicios de producción. La prueba Android pública no necesita credenciales ni crea pedidos.
