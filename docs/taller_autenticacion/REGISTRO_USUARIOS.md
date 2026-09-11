# Registro de usuarios

DeliverPuyo contempla autorregistro público en la implementación actual.

El backend expone el endpoint real:

```text
POST /api/auth/register
```

Body esperado:

```json
{
  "name": "Nombre del cliente",
  "email": "correo@ejemplo.com",
  "password": "Contraseña segura"
}
```

Validaciones reales del backend:

- `name`: requerido, mínimo 3 y máximo 120 caracteres.
- `email`: requerido y con formato de correo válido.
- `password`: mínimo 8 y máximo 100 caracteres, debe incluir una mayúscula y un número.

La aplicación móvil incluye un formulario de registro que usa ese endpoint real. Si el registro es correcto, el backend devuelve usuario, access token, refresh token y tiempo de expiración; la app crea un `AuthSession` igual que en login.

No se documentan contraseñas ni tokens en este archivo.
