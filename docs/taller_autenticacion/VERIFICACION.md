# Verificación del taller

## Login

- Endpoint real: `POST /api/auth/login`.
- Método: `POST`.
- Body: `email`, `password`.
- Respuesta correcta: `success=true` con usuario, access token, refresh token y expiración.
- Error 401: la app muestra `Correo o contraseña incorrectos.`
- Error 422: la app muestra mensajes comprensibles sin detalles internos.

## Validaciones

- Correo requerido: verificado en formulario Flutter.
- Formato de correo: verificado en formulario Flutter.
- Contraseña requerida: verificado en formulario Flutter.
- Registro: validaciones alineadas con `validations/auth.ts`.

## Autenticación

- `AuthSession` guarda usuario, access token, refresh token y expiración.
- `AuthController` representa `Authenticated`, `Unauthenticated`, `AuthLoading` y `AuthFailure`.
- La contraseña no se guarda en estado.

## Navegación

- `go_router` vive en `mobile/lib/router/app_router.dart`.
- Rutas públicas: `/login`, `/register`, `/products`.
- Rutas protegidas: `/products/:id`, `/orders`, `/orders/new`, `/profile`.
- El destino pretendido se conserva con `from`.
- `from` se valida como ruta interna.

## Riverpod y estado

- `authControllerProvider`: sesión.
- `productsControllerProvider`: catálogo remoto.
- `ordersControllerProvider`: pedidos y creación.
- `orderDraftProvider`: borrador de pedido.
- `RemoteState<T>` representa initial, loading, data, empty y error.

## Logout

- Botón visible: `Cerrar sesión` en `ProfileScreen`.
- Acción: `AuthController.logout()`.
- Resultado: sesión eliminada y regreso a `/login`.

## Registro

- Autorregistro: sí existe en backend.
- Endpoint: `POST /api/auth/register`.
- Formulario móvil: `/register`.
- No se inventaron endpoints ni campos.

## Pruebas

Ejecutar desde `mobile`:

```powershell
dart format .
flutter analyze
flutter test
```

Registrar aquí el resultado real después de ejecutar:

- `dart format`: OK. Se ejecutó `dart format .` con Dart 3.12.2 y formateó 40 archivos.
- `flutter analyze`: OK. Resultado: `No issues found!`.
- `flutter test`: OK. Resultado: `All tests passed!`.
- Total real de tests: 28.

## Evidencias Android

Las capturas reales del emulador están en `evidence/taller_autenticacion/`.

- `01_login.png`
- `02_validacion_correo_vacio.png`
- `03_validacion_correo_invalido.png`
- `04_validacion_password.png`
- `05_credenciales_incorrectas.png`
- `06_login_correcto.png`
- `07_productos.png`
- `08_detalle_producto.png`
- `09_pedidos.png`
- `10_perfil_sesion.png`
- `11_logout.png`
- `12_ruta_protegida_post_logout.png`
- `13_registro.png`

Ambiente usado:

- AVD: `DeliverPuyo_API_36`
- Device ID: `emulator-5554`
- Android: 16
- API: 36
- `sys.boot_completed`: 1
