# Contrato API — Semana 13

Fuentes inspeccionadas: `services/product.service.ts`, `services/order.service.ts`, `services/auth.service.ts`, `pages/api/auth/refresh.ts`, `pages/api/orders/index.ts`, `validations/orders.ts`, `prisma/schema.prisma`.

Base de desarrollo Android: `http://10.0.2.2:3000`. API local verificada: GET /api/products, success=true, 15 productos. No se modificó el contrato.

## Product

| Campo backend | Campo Flutter | Tipo backend | Tipo Dart | Opcional | Observación |
|---|---|---|---|---|---|
| id | id | UUID/string | String | No | Mismo nombre |
| name | name | string | String | No | Mismo nombre |
| price | price | Prisma Decimal, JSON string | double | No | Conversor también admite JSON numérico |
| stock | stock | integer | int | No | Mismo nombre |
| imageUrl | imageUrl | string/null | String? | Sí | Mismo nombre camelCase |
| description | description | string/null en entidad | String? | Sí | El listado NO permite seleccionarlo; llega ausente y se conserva null |
| category.name | categoryName | objeto category con name string | String? | Sí | Proyección real de objeto anidado; JsonKey(name: 'category') con conversores |

GET /api/products solicita page=1, limit=50 y fields=id,name,price,stock,imageUrl,category. La respuesta contiene success, data[], pagination y cache. El cliente no consume todas las páginas; este prototipo conserva el límite existente de 50.

Product.toJson reconstruye category: {name}; no inventa category.id. Es una proyección de lectura/caché, no un DTO para crear productos. No hay divergencias snake_case/camelCase ficticias.

## OrderSummary

| Campo backend | Campo Flutter | Tipo backend | Tipo Dart | Opcional | Observación |
|---|---|---|---|---|---|
| id | id | UUID/string | String | No | Mismo nombre |
| status | status | enum, JSON string | String | No | Mismo nombre; se conserva el valor del servidor |
| total | total | Prisma Decimal, JSON string | double | No | Conversión decimal |
| createdAt | createdAt | DateTime, JSON ISO 8601 | String | No | Se conserva ISO para compatibilidad con las pantallas existentes |

El resumen omite deliberadamente items, subtotal y deliveryFee. No son campos ausentes del backend: quedan fuera de la proyección usada por la UI actual.

POST /api/orders: {addressId: UUID, items: [{productId: UUID, quantity: entero 1..50}]}. Devuelve 201, success y data del pedido. La validación admite 1..30 ítems y rechaza productos repetidos. No existe clientOperationId ni Idempotency-Key.

422 de esquema: errors.addressId y/o errors.items son arrays de mensajes porque Zod usa flatten().fieldErrors. CreateOrderScreen asocia items con producto/cantidad. No se inventa un campo quantity independiente en esa respuesta.

## Autenticación

POST /api/auth/login: email, password. POST /api/auth/register: name, email, password. Respuesta data: user {id,name,email,role}, accessToken, refreshToken, expiresInSeconds.

POST /api/auth/refresh: {refreshToken}. Respuesta 200 data: accessToken, refreshToken, expiresInSeconds, sin user. Se conserva el usuario actual al renovar. El servidor verifica firma, caducidad, revocación y estado activo; revoca el refresh anterior y emite otro. El TTL predeterminado del código es 15 minutos; el TTL operativo no se inspeccionó leyendo secretos ni se cambió.

Rutas protegidas consumidas: /api/addresses, /api/orders, POST /api/categories (prueba de permisos preexistente). Rutas públicas: productos, categorías GET, login y registro. El refresh no lleva Authorization; usa su cuerpo específico.
