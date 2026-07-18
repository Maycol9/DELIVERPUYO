# Especificación - Avance 8

## Objetivo
Optimizar el backend de DeliverPuyo sin alterar su comportamiento funcional ni debilitar la seguridad.

## Criterios de aceptación
- El catálogo utiliza cache-aside, TTL e invalidación.
- El listado de pedidos no genera consultas N+1.
- La tarea de generar comprobante se ejecuta en un worker.
- Las relaciones se cargan según el patrón de acceso.
- JWT se verifica sin consulta redundante por solicitud.
- Las respuestas usan paginación, selección de campos y compresión.
- Existe una comparación reproducible antes/después.
