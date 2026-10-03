# Autenticacion

Endpoint real: `POST /api/auth/login`.

Body:

```json
{ "email": "cliente@deliverpuyo.local", "password": "Cliente1234" }
```

Respuesta exitosa: `200` con `data.user`, `data.accessToken`, `data.refreshToken` y `data.expiresInSeconds`.

401 limpia la sesion con el mensaje: "Tu sesion termino. Inicia sesion nuevamente." 403 no limpia token ni usuario; se muestra "No tienes permiso para realizar esta accion."

El destino pretendido se conserva en `from` y se valida como ruta interna antes de usarlo.
