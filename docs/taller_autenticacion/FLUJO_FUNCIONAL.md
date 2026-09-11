# Flujo funcional

## Login

La pantalla `/login` muestra correo, contraseña y el botón `INGRESAR`.

Validaciones:

- Correo vacío: `Ingresa tu correo electrónico.`
- Correo inválido: `Ingresa un correo electrónico válido.`
- Contraseña vacía: `Ingresa tu contraseña.`

Credenciales incorrectas:

- La app llama a `POST /api/auth/login`.
- El backend responde rechazo.
- La UI muestra `Correo o contraseña incorrectos.`
- No se muestra stack trace, token ni respuesta interna.

Login correcto:

- La app recibe `user`, `accessToken`, `refreshToken` y `expiresInSeconds`.
- Riverpod cambia a `Authenticated`.
- La navegación continúa al destino solicitado o a `/products`.

## Registro

Existe autorregistro real en `POST /api/auth/register`.

La app móvil tiene pantalla `/register` con nombre, correo y contraseña. Las reglas del formulario siguen las validaciones del backend.

## Navegación

Rutas principales:

- `/login`
- `/register`
- `/products`
- `/products/:id`
- `/orders`
- `/orders/new`
- `/profile`

Flujo demostrado:

```text
Login -> Productos -> Detalle de producto -> Pedidos -> Perfil -> Logout
```

## Rutas protegidas

Sin sesión:

- `/orders` redirige a `/login?from=/orders`
- `/orders/new` redirige a login
- `/profile` redirige a login
- `/products/:id` redirige a login

Con sesión:

- El usuario puede acceder a pedidos, crear pedido, perfil y detalle protegido.

El parámetro `from` solo acepta rutas internas para evitar redirecciones externas.

## Estado

Riverpod mantiene durante la ejecución:

- `AuthSession`
- usuario autenticado
- access token
- refresh token
- catálogo de productos
- pedidos
- borrador de pedido

El borrador de pedido conserva dirección, producto y cantidad al navegar y volver.

## Logout

El botón `Cerrar sesión` está en `/profile`.

Al pulsarlo:

- Se ejecuta `AuthController.logout()`.
- Se elimina `AuthSession` del estado.
- La app navega a `/login`.
- Un nuevo intento de entrar a rutas protegidas vuelve a login.
