# Estado de aplicacion

| Dato | Tipo | Justificacion |
| --- | --- | --- |
| Mostrar/ocultar contrasena | Efimero | Solo afecta a LoginScreen. |
| Texto de busqueda | Efimero | Solo filtra visualmente ProductsScreen. |
| Categoria seleccionada | Efimero | Solo afecta al catalogo visible. |
| Token de acceso | Aplicacion | Lo necesitan rutas protegidas y servicios REST. |
| Usuario autenticado | Aplicacion | Perfil, proteccion de rutas y permisos. |
| Estado de autenticacion | Aplicacion | Define redirect y flujo login/logout. |
| Catalogo remoto | Aplicacion | Se comparte entre listado y detalle por URL. |
| Borrador de pedido | Aplicacion | Debe sobrevivir al navegar y regresar. |

El token vive en memoria durante la sesion actual. No se agrego persistencia segura porque no era requisito indispensable de esta semana y el proyecto no tenia una implementacion previa.
