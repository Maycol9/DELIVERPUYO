# Checklist de rúbrica — Prototipo 13

Autoevaluación técnica conservadora; no sustituye calificación docente. Total potencial de la rúbrica: 10/10. No se asigna puntaje completo a apartados cuya demostración autenticada real está pendiente.

| Apartado | Verificado | Estimación |
|---|---|---:|
| Configuración centralizada | Dio único, base por compilación, timeouts, ambientes y validateStatus | 1.0 / 1.0 |
| Interceptor de autenticación | Header automático y rutas públicas con fakes; plugin seguro real Android; login real pendiente | 1.0 / 1.5 |
| Renovación automática | Contrato real inspeccionado; 401, single-flight, anti-bucle, cierre y carreras con fakes; falta expiración real | 1.5 / 2.5 |
| Serialización | Product/OrderSummary generados y probados; contrato y null documentados | 1.5 / 1.5 |
| Capa de datos | Caché real online/offline/reconexión; cola persistente probada con fakes; falta envío real de outbox | 1.0 / 1.5 |
| Errores y reintentos | Cuatro familias, GET limitado, POST sin repetición ambigua, cancelación y 422 en widget | 1.5 / 1.5 |
| Seguridad | HTTPS prod, logs redactados, plugin seguro, .env ignorado, sin secretos de backend en lib | 0.5 / 0.5 |
| **TOTAL ESTIMADO VERIFICADO** | Evidencia autenticada incompleta | **8.0 / 10** |

Aunque el manejo 422 se verifica por pruebas, su captura con respuesta real del endpoint protegido sigue pendiente. No se fabricaron capturas 03–08. El inventario EVIDENCIAS.md distingue formulario de login de login exitoso y refresco del catálogo de sincronización real de pedidos.
