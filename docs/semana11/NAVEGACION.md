# Navegacion

La app usa `go_router` en `mobile/lib/router/app_router.dart`.

La ruta anidada principal es `/products/:id`. La pantalla recibe solo `productId` desde `state.pathParameters`, no un objeto `Product` por `extra`. Esto permite abrir directamente una URL como `/products/<id>` y reconstruir la pantalla consultando datos reales.

Como no existe `GET /api/products/[id]` para lectura individual, la reconstruccion usa `GET /api/products` y localiza el producto por ID en el resultado. Esta decision evita inventar endpoints.

Las rutas protegidas redirigen a `/login?from=<destino>`. El parametro `from` se acepta solo si es una ruta interna, sin esquema ni host, para evitar open redirects. Tras login correcto, la app vuelve al destino pretendido.
