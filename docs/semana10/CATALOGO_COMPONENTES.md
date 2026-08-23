# Catálogo de componentes Semana 10

## AppPrimaryButton

Propósito: acción principal reutilizable para iniciar sesión, guardar, confirmar, crear pedido o reintentar.

Justificación: repetición, cohesión, estabilidad de interfaz e independencia de contexto.

| Elemento | Nombre | Tipo | Obligatorio | Valor por defecto | Función |
| -------- | ------ | ---- | ----------- | ----------------- | ------- |
| Dato | `text` | `String` | Sí | - | Texto visible y etiqueta semántica. |
| Configuración | `loading` | `bool` | No | `false` | Muestra progreso y desactiva la acción. |
| Configuración | `enabled` | `bool` | No | `true` | Habilita o deshabilita interacción. |
| Callback | `onPressed` | `VoidCallback?` | Sí | - | Comunica la intención al padre. |
| Contenido delegado | `icon` | `Widget?` | No | `null` | Icono opcional compuesto desde fuera. |

Estados: normal, disabled, loading.

Es reutilizable porque no conoce endpoints, rutas ni negocio; recibe datos por parámetros, expone callback y usa tema/tokens.

## AppTextField

Propósito: entrada de texto para formularios y búsqueda.

Justificación: repetición en login, registro, direcciones, filtros y formularios administrativos.

| Elemento | Nombre | Tipo | Obligatorio | Valor por defecto | Función |
| -------- | ------ | ---- | ----------- | ----------------- | ------- |
| Dato | `label` | `String` | Sí | - | Nombre visible del campo. |
| Dato | `controller` | `TextEditingController?` | No | `null` | Control externo del valor. |
| Dato | `initialValue` | `String?` | No | `null` | Valor inicial sin controller. |
| Callback | `onChanged` | `ValueChanged<String>?` | No | `null` | Informa cambios al padre. |
| Configuración | `errorText` | `String?` | No | `null` | Mensaje de error visible. |
| Configuración | `obscureText` | `bool` | No | `false` | Oculta texto en contraseñas. |
| Configuración | `keyboardType` | `TextInputType?` | No | `null` | Tipo de teclado. |
| Configuración | `enabled` | `bool` | No | `true` | Habilita edición. |
| Contenido delegado | `prefix` | `Widget?` | No | `null` | Widget al inicio. |
| Contenido delegado | `suffix` | `Widget?` | No | `null` | Widget al final. |

Estados: normal, focused, disabled, error.

## StateView

Propósito: representar cargando, vacío y error sin repetir lógica visual.

Justificación: aparece en listados de productos, categorías, direcciones y pedidos.

| Elemento | Nombre | Tipo | Obligatorio | Valor por defecto | Función |
| -------- | ------ | ---- | ----------- | ----------------- | ------- |
| Configuración | `type` | `StateViewType` | Sí | - | Selecciona loading, empty o error. |
| Dato | `message` | `String` | Sí | - | Mensaje comprensible para usuario. |
| Dato | `title` | `String?` | No | `null` | Título opcional. |
| Callback | `onRetry` | `VoidCallback?` | No | `null` | Acción de reintento. |
| Configuración | `actionText` | `String` | No | `REINTENTAR` | Texto del botón de error. |
| Contenido delegado | `child` | `Widget?` | No | `null` | Contenido adicional. |

Estados: loading, empty, error.

## ProductCard

Propósito: mostrar un producto recibido por parámetros.

Justificación: el catálogo, búsqueda, pedidos y favoritos podrían necesitar una representación estable de producto.

| Elemento | Nombre | Tipo | Obligatorio | Valor por defecto | Función |
| -------- | ------ | ---- | ----------- | ----------------- | ------- |
| Dato | `name` | `String` | Sí | - | Nombre del producto. |
| Dato | `price` | `double` | Sí | - | Precio mostrado. |
| Dato | `stock` | `int` | Sí | - | Disponibilidad. |
| Dato | `description` | `String?` | No | `null` | Descripción opcional. |
| Dato | `category` | `String?` | No | `null` | Categoría visible. |
| Dato | `imageUrl` | `String?` | No | `null` | Imagen remota opcional. |
| Callback | `onTap` | `VoidCallback?` | No | `null` | Selección del producto. |
| Contenido delegado | `trailing` | `Widget?` | No | `null` | Acción o indicador final. |
| Configuración | `compact` | `bool` | No | `false` | Variante para grillas anchas. |

Estados: normal, pressed, sin imagen, sin stock.

No consulta la API, no decide navegación y no conoce `API_URL`; solo representa datos.

## CategoryFilterChip

Propósito: filtrar visualmente el catálogo por categorías derivadas de productos reales.

Justificación: permite reutilizar filtros en productos, pedidos u otros listados con categorías o estados.

| Elemento | Nombre | Tipo | Obligatorio | Valor por defecto | Función |
| -------- | ------ | ---- | ----------- | ----------------- | ------- |
| Dato | `label` | `String` | Sí | - | Texto visible del filtro. |
| Configuración | `selected` | `bool` | Sí | - | Indica si el filtro está activo. |
| Callback | `onSelected` | `ValueChanged<bool>` | Sí | - | Comunica al padre la intención de seleccionar. |

Estados: normal, selected, focused, pressed.

Es reutilizable porque no consulta backend, no conoce productos, no decide navegación y expone el cambio mediante callback. Consume `ThemeData` y `AppTokens`, y declara semánticamente cuando un filtro está seleccionado.
