# Rúbrica técnica — Semana 13

Estado actual, no nota oficial. No se declara 10/10 mientras falten evidencias reales.

| Criterio | Evidencia | Estimación conservadora |
|---|---|---:|
| Cliente | Dio único, ambientes, timeouts, justificación | 1.0/1.0 |
| Autenticación | Login manual, sesión cifrada, rutas protegidas reales | 1.5/1.5 |
| Renovación | GET 401→una renovación→retry 200; anti-bucle y concurrencia PASS; falta correlación visual 05/06 | 2.0/2.5 |
| Serialización | Product y OrderSummary generados, null/mapping y pedido real | 1.5/1.5 |
| Datos | Remoto/local/repositorio, caché real y único pedido real | 1.5/1.5 |
| Errores | Cuatro familias y reintentos probados; 422 real por campo, formulario conservado y diagnóstico PROD bloqueado | 1.5/1.5 |
| Seguridad | HTTPS/logging PROD/bloqueo diagnóstico probados; capturas sin secretos | 0.5/0.5 |
| TOTAL | Correlación visual de refresh pendiente | 9.5/10 |

La outbox se prueba con fakes y no se presenta como envío real offline. La búsqueda previa del seed expuso accidentalmente credenciales de prueba; no se oculta esa incidencia ni se reproducen los valores. El middleware recibió una corrección de manejo de errores, sin cambios de reglas de validación ni secretos.
