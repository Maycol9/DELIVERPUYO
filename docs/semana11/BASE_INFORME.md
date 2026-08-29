# Base de informe - Avance 11

Se implemento navegacion declarativa con `go_router`, rutas publicas y protegidas, ruta anidada `/products/:id`, parametro por URL y conservacion del destino pretendido con `from`.

Riverpod administra el estado de autenticacion, catalogo remoto, pedidos y borrador de pedido. El estado efimero permanece local en las pantallas cuando no necesita compartirse.

El formulario de creacion de pedidos usa el contrato real `POST /api/orders`: `addressId` e `items`. Las reglas del backend se reflejan en Flutter y los errores 422 se asocian a campos cuando el backend los devuelve.

La diferencia entre 401 y 403 queda implementada: 401 cierra sesion; 403 conserva sesion y muestra un mensaje de permisos.
