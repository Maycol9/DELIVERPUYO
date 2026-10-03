# Inventario de pantallas Semana 10

Inventario derivado de los endpoints reales encontrados en `pages/api/`.

| Pantalla | Endpoint real | Método HTTP | Propósito |
| -------- | ------------- | ----------- | --------- |
| Inicio de sesión | `/api/auth/login` | POST | Autenticar usuario y obtener tokens. |
| Registro | `/api/auth/register` | POST | Crear cuenta de cliente. |
| Renovar sesión | `/api/auth/refresh` | POST | Renovar access token con refresh token. |
| Categorías | `/api/categories` | GET | Listar categorías activas. |
| Crear categoría | `/api/categories` | POST | Crear categoría administrativa protegida. |
| Catálogo de productos | `/api/products` | GET | Listar productos activos con paginación y campos seleccionados. |
| Crear producto | `/api/products` | POST | Crear producto administrativo protegido. |
| Editar producto | `/api/products/{id}` | PATCH | Actualizar producto administrativo protegido. |
| Direcciones | `/api/addresses` | GET | Listar direcciones del usuario autenticado. |
| Crear dirección | `/api/addresses` | POST | Registrar una dirección del usuario autenticado. |
| Pedidos | `/api/orders` | GET | Listar pedidos del usuario o del administrador. |
| Crear pedido | `/api/orders` | POST | Crear pedido con dirección e items. |
| Detalle de pedido | `/api/orders/{id}?include=address` | GET | Consultar detalle del pedido y dirección opcional. |

## Patrones visuales reutilizables

| Patrón | Pantallas donde se repite | Componente propuesto |
| ------ | ------------------------- | -------------------- |
| Acción principal | Login, registro, crear pedido, reintentar, guardar | `AppPrimaryButton` |
| Entrada de datos | Login, registro, direcciones, búsqueda, productos admin | `AppTextField` |
| Cargando, vacío y error | Productos, categorías, direcciones, pedidos | `StateView` |
| Resumen de entidad | Productos, pedidos, direcciones | `ProductCard` para productos; patrón extensible a tarjetas de dominio. |

La pantalla implementada para Semana 10 es `Catálogo de productos` porque `GET /api/products` es un endpoint público real y no requiere autenticación para demostrar consumo de API.
