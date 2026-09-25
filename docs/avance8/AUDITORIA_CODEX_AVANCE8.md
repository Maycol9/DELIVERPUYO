# Auditoria Codex Avance 8

Proyecto: DeliverPuyo  
Estudiante: Maycol Sleyter Perez Figueroa  
Asignatura: Aplicaciones Moviles  
Institucion: Universidad Estatal Amazonica  
Fecha de auditoria: 2026-07-18

## Resumen ejecutivo

DeliverPuyo implementa un backend REST para una aplicacion movil de delivery. La arquitectura revisada usa Next.js API Routes, TypeScript, Prisma ORM con PostgreSQL, Redis, BullMQ, JWT, Zod, bcrypt y Docker Compose.

El proyecto cumple la base del Avance 8: cache-aside para catalogo, comparacion N+1 contra eager loading, worker para comprobantes PDF, autenticacion con access/refresh token, respuestas reducidas para movil y evidencias reales. La auditoria corrigio referencias residuales, paginacion inconsistente, validacion de UUID en rutas dinamicas, estado BYPASS de cache y conservacion del resultado JSON de benchmark.

## Arquitectura encontrada

- `pages/api`: endpoints REST consumidos por la app movil.
- `services`: logica de negocio para productos, pedidos y autenticacion.
- `validations`: esquemas Zod para entradas HTTP.
- `prisma`: schema, migraciones y seed.
- `lib`: JWT, Redis, colas, entorno y router comun.
- `workers`: worker BullMQ de comprobantes PDF.
- `scripts`: benchmark y verificacion de cola.
- `evidence`: resultados reales del Avance 8.

## Hallazgos corregidos

| Prioridad | Hallazgo | Accion |
|---|---|---|
| P1 | README mencionaba un proyecto externo | Se identifico el proyecto solo como DeliverPuyo |
| P1 | `GET /api/orders` no devolvia metadata de paginacion | Se agrego `pagination` con `page`, `limit`, `total`, `pages` |
| P1 | `GET /api/addresses` no tenia paginacion | Se agrego paginacion y conteo total |
| P1 | Rutas `[id]` no validaban UUID antes del servicio | Se agrego validacion Zod y respuesta 422 |
| P1 | Cache omitido no exponia `BYPASS` | Se agrego estado `BYPASS` cuando `x-bypass-cache: 1` |
| P1 | `benchmark-results.json` estaba ignorado | Se permitio conservar evidencia JSON |
| P1 | Faltaba documentacion formal de Avance 8 | Se crearon documentos en `docs/avance8` |

## Seguridad

- Las contrasenas se almacenan con bcrypt.
- El access token JWT contiene `sub`, `email` y `role`, y se verifica localmente.
- El refresh token se firma, se guarda hasheado y se rota al renovar.
- Los endpoints protegidos distinguen 401 y 403.
- `.env` esta ignorado y no se debe versionar.
- No se detectaron secretos reales versionados durante la auditoria.

## Rendimiento

- `GET /api/products` usa cache-aside con Redis y TTL de 120 segundos.
- La clave de cache considera pagina, limite, categoria, busqueda y campos.
- El listado de pedidos usa eager loading con `relationLoadStrategy: "join"`.
- El detalle de pedido carga direccion solo con `?include=address`.
- El PDF se genera fuera de la solicitud principal mediante BullMQ.

## Referencias residuales

Se encontro una referencia residual a un proyecto externo en `README.md`. Fue corregida. No se encontraron referencias relevantes a repositorios docentes, entidades deportivas ni rutas absolutas personales en codigo fuente revisado.

## Evidencias reales

- Cache: MISS 103.91 ms, HIT 1 13.36 ms, HIT 2 11.31 ms.
- N+1: 20 pedidos, 81 consultas, 93.69 ms internos, 153.80 ms HTTP.
- Optimizado: 20 pedidos, 1 consulta, 6.80 ms internos, 17.12 ms HTTP.
- BullMQ: `wait: 0`, `active: 0`, `completed: 1`, `failed: 0`, `delayed: 0`, `paused: 0`.
- PDF generado en `storage/receipts`.

## Riesgos pendientes

- Las capturas finales para el video deben tomarse manualmente sin mostrar tokens completos ni `.env`.
- Si se vuelve a ejecutar benchmark despues de ajustes de `BYPASS`, los resultados pueden cambiar; conservar las metricas reales ya registradas.
- Se recomienda no ejecutar `prisma migrate reset` ni comandos destructivos durante la presentacion.
