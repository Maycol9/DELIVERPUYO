# Mapa de rutas - Semana 11

| Ruta movil | Pantalla | Publica/Protegida | Endpoint | Metodo |
| --- | --- | --- | --- | --- |
| `/login` | LoginScreen | Publica | `/api/auth/login` | POST |
| `/products` | ProductsScreen | Publica | `/api/products` | GET |
| `/products/:id` | ProductDetailScreen | Protegida | `/api/products` | GET |
| `/orders` | OrdersScreen | Protegida | `/api/orders` | GET |
| `/orders/new` | CreateOrderScreen | Protegida | `/api/orders` | POST |
| `/profile` | ProfileScreen | Protegida | estado de autenticacion local | N/A |

`/products/:id` es una ruta anidada dentro de `/products`. El backend no expone `GET /api/products/[id]`; por eso la pantalla reconstruye el detalle consultando el catalogo real y filtrando por `id`.
