# Matriz De Cumplimiento Avance 8

| Requisito | Estado | Evidencia |
|---|---|---|
| API REST para app movil | Cumple | `pages/api` |
| Cliente movil no accede a PostgreSQL/Redis | Cumple | Backend centraliza datos y cache |
| Cache cache-aside en productos | Cumple | `services/product.service.ts` |
| Clave por pagina, limite, categoria, busqueda y campos | Cumple | `products:list:*` |
| TTL 120 segundos | Cumple | `PRODUCT_CACHE_TTL_SECONDS=120` |
| Estados MISS/HIT/BYPASS | Cumple | Header `X-Cache` y cuerpo JSON |
| Redis como optimizacion no critica | Cumple | `try/catch` con fallback a PostgreSQL |
| Invalidacion al crear/actualizar/desactivar producto | Cumple | `invalidatePattern('products:list:*')` |
| Comparacion N+1 academica | Cumple | `benchmarkNPlusOne` |
| Version optimizada sin N+1 | Cumple | `benchmarkOptimized` con eager loading |
| Eager loading en listado de pedidos | Cumple | `listOptimized` |
| Carga opcional de direccion | Cumple | `GET /api/orders/{id}?include=address` |
| Cola BullMQ para PDF | Cumple | `order-receipts` |
| Worker con mensaje requerido | Cumple | `Worker de comprobantes activo` |
| `jobId` compatible con BullMQ | Cumple | `receipt-${job.orderId}` |
| Intentos y backoff exponencial | Cumple | `attempts: 5`, backoff exponential |
| Access token 15 minutos | Cumple | `.env.example` y `env.ts` |
| Refresh token 7 dias | Cumple | `.env.example` y `env.ts` |
| Refresh token hasheado | Cumple | `hashToken` + tabla `refresh_tokens` |
| Middleware JWT sin consulta por request | Cumple | `middleware/auth.ts` |
| Roles CLIENT y ADMIN | Cumple | `schema.prisma` |
| Paginacion maxima 50 | Cumple | `helper/pagination.ts` |
| Seleccion de campos en productos | Cumple | `fields` + Prisma `select` |
| Compresion HTTP | Cumple | `next.config.ts` |
| Evidencias reales conservadas | Cumple | `evidence/*` |
| Documentacion de IA | Cumple | `docs/avance8/USO_RESPONSABLE_IA.md` |
| Ausencia de referencia docente residual | Cumple despues de correccion | README corregido |
| `.env` ignorado | Cumple | `.gitignore` |
| `node_modules`, `.next`, `generated`, `storage/receipts` ignorados | Cumple | `.gitignore` |

## Resultados reales

| Metrica | Antes | Despues | Reduccion |
|---|---:|---:|---:|
| Cache HTTP | 103.91 ms | 11.31 ms | 89.12 % |
| Consultas N+1 | 81 | 1 | 98.77 % |
| Tiempo interno | 93.69 ms | 6.80 ms | 92.74 % |
| Tiempo HTTP | 153.80 ms | 17.12 ms | 88.87 % |

Las cifras anteriores provienen de `evidence/benchmark-results.json` y no fueron reemplazadas por estimaciones.
