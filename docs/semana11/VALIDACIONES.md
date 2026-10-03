# Validaciones

## Login

| Campo | Regla backend | Validacion Flutter | Mensaje usuario |
| --- | --- | --- | --- |
| email | string email | requerido y contiene `@` | Ingresa un correo valido. |
| password | min(1) | requerido | Ingresa tu contrasena. |

## Pedido

| Campo | Regla backend | Validacion Flutter | Mensaje usuario |
| --- | --- | --- | --- |
| addressId | UUID requerido | seleccion obligatoria | Selecciona una direccion. |
| items | arreglo min 1 max 30 | se envia un item desde el formulario | Selecciona un producto. |
| items.productId | UUID requerido | seleccion obligatoria | Selecciona un producto. |
| items.quantity | entero positivo max 50 | entero, mayor que cero, maximo 50 | La cantidad debe ser mayor que cero. |

Los errores 422 del backend llegan como `{ success, message, errors }`. Flutter extrae `errors` por campo y los muestra junto al campo correspondiente cuando es posible. Los errores generales se muestran como mensaje de formulario.
