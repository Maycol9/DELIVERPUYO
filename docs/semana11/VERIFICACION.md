# Verificacion

Comandos ejecutados en `mobile`:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Resultado:

- `flutter pub get`: dependencias resueltas.
- `dart format .`: formateo correcto.
- `flutter analyze`: No issues found.
- `flutter test`: All tests passed, 24 pruebas.

## Verificaciones de cierre tecnico

- Reconstruccion `/products/:id`: verificada por codigo y test. `ProductDetailScreen` recibe solo `productId` desde la ruta y reconstruye con `ProductsController`; no depende de `extra`.
- 422: verificado por test seguro. `ApiException.fromStatus(422)` extrae errores por campo, `OrdersController.create` los devuelve al formulario y `orderDraftProvider` conserva `addressId`, `productId` y `quantity`.
- 401: verificado por test. `handleUnauthorized()` limpia la sesion y cambia a `Unauthenticated`; el router puede redirigir a login para rutas protegidas.
- 403: verificado por test seguro. Un `RemoteError` con 403 conserva `AuthSession`, token y usuario autenticado, y muestra mensaje de falta de permisos.

## Evidencias visuales reales disponibles

- Login: `evidence/semana11/01_login.png`.
- Ruta protegida a login: `evidence/semana11/03_ruta_protegida.png`.
- Login exitoso/listado de pedidos: `evidence/semana11/02_login_exitoso.png`.
- Catalogo: `evidence/semana11/04_catalogo_productos.png`.
- Detalle de producto: `evidence/semana11/05_detalle_producto.png`.
- Formulario: `evidence/semana11/07_formulario_creacion.png`.
- Validacion de campo: `evidence/semana11/08_validacion_campo.png`.
- Creacion real de pedido: `evidence/semana11/10_registro_creado.png`.
- 401 visual: `evidence/semana11/11_error_401.png`.
- Conservacion del formulario: `evidence/semana11/13_formulario_conservado.png`.

No se forzaron capturas para 422 ni 403. Quedan cerrados por pruebas automatizadas sin alterar backend, roles ni permisos.
