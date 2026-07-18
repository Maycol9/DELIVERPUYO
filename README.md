# DeliverPuyo - Avance 8: optimización del backend

Backend académico adaptado a la estructura del repositorio **Canchago**, con Next.js, TypeScript, Prisma/PostgreSQL, Redis, BullMQ, JWT y Zod.

## Mejoras implementadas

1. **Caché cache-aside** en `GET /api/products`, Redis, TTL de 120 segundos e invalidación explícita al crear o actualizar productos.
2. **Corrección de N+1** en el listado de pedidos mediante `relationLoadStrategy: 'join'`, eager loading y selección de campos.
3. **Lazy/eager loading justificado**: listados cargan relaciones necesarias; el detalle solo carga dirección si `?include=address`.
4. **Cola de trabajo** con BullMQ: la creación de un pedido encola un comprobante PDF y responde inmediatamente.
5. **Autenticación eficiente**: el access token JWT se valida localmente; no se consulta la base en cada solicitud protegida. El refresh token sí se valida contra la base para permitir revocación.
6. **Respuesta optimizada**: paginación máxima 50, selección de campos mediante `fields`, compresión HTTP y JSON reducido.
7. **Evidencia automática**: endpoint de benchmark y script que guarda resultados reales en `evidence/benchmark-results.json`.

## Requisitos

- Node.js 22+
- Docker Desktop o PostgreSQL 17 + Redis 7

## Ejecución paso a paso

```powershell
Copy-Item .env.example .env
docker compose up -d
npm install
npm run generate
npm run migrate-dev -- --name init
npm run seed
```

Terminal 1:
```powershell
npm run dev
```

Terminal 2:
```powershell
npm run worker:receipt
```

Terminal 3, para generar evidencia real:
```powershell
npm run benchmark
```

## Usuarios de prueba

- Administrador: `admin@deliverpuyo.local` / `Admin1234`
- Cliente: `cliente@deliverpuyo.local` / `Cliente1234`

## Endpoints principales

| Método | Endpoint | Protección | Optimización |
|---|---|---|---|
| POST | `/api/auth/register` | Público | Hash bcrypt + JWT |
| POST | `/api/auth/login` | Público | Emite access/refresh token |
| POST | `/api/auth/refresh` | Público con refresh | Rotación y revocación |
| GET | `/api/categories` | Público | Catálogo reducido |
| GET/POST | `/api/addresses` | JWT | Solo direcciones del usuario |
| GET | `/api/products` | Público | Redis, paginación, fields, gzip |
| POST | `/api/products` | ADMIN | Invalida caché |
| PATCH | `/api/products/{id}` | ADMIN | Invalida caché |
| GET | `/api/orders` | JWT | Eager loading / JOIN |
| POST | `/api/orders` | JWT | Transacción + cola PDF |
| GET | `/api/orders/{id}?include=address` | JWT | Carga opcional controlada |
| GET | `/api/debug/orders-benchmark` | ADMIN | Evidencia N+1 vs JOIN |

## Evidencias sugeridas para el video

1. Postman: primera consulta de productos `X-Cache: MISS` y segunda `X-Cache: HIT`.
2. Actualizar un producto y comprobar que la siguiente consulta vuelve a `MISS`.
3. Ejecutar benchmark N+1 y optimizado; comparar `databaseCalls` y `durationMs`.
4. Crear un pedido: observar respuesta inmediata y luego PDF en `storage/receipts`.
5. Mostrar que middleware JWT no ejecuta consulta de usuario por cada solicitud.
6. Abrir `evidence/benchmark-results.json` generado por el script.

## Nota de honestidad académica

Los tiempos dependen del computador y deben obtenerse ejecutando `npm run benchmark`. El proyecto no incluye cifras inventadas; genera la evidencia técnica real en el entorno del estudiante.
