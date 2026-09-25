# Guia De Ejecucion Avance 8

## Requisitos

- Node.js 22 o superior.
- Docker Desktop.
- PowerShell.
- PostgreSQL y Redis mediante `docker-compose.yml`.

## Preparacion

```powershell
Copy-Item .env.example .env
npm install
docker compose up -d
npx prisma generate
npx prisma migrate deploy
npm run seed
```

No modificar ni mostrar el contenido real de `.env` en capturas o video.

## Servidor API

Terminal 1:

```powershell
npm run dev
```

La API queda disponible en:

```text
http://localhost:3000
```

## Worker BullMQ

Terminal 2:

```powershell
npm run worker:receipt
```

Mensaje esperado:

```text
Worker de comprobantes activo
```

## Benchmark

Terminal 3:

```powershell
npm run benchmark
```

El script genera o actualiza:

```text
evidence/benchmark-results.json
```

Para revisar BullMQ:

```powershell
npx tsx --env-file=.env scripts/check-queue.ts
```

Estado real registrado:

```text
{ wait: 0, active: 0, completed: 1, failed: 0, delayed: 0, paused: 0 }
```

## Endpoints para demostrar

- `GET /api/products?page=1&limit=5&fields=id,name,price,stock`
- `GET /api/orders?page=1&limit=20`
- `GET /api/orders/{id}?include=address`
- `POST /api/orders`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `GET /api/addresses?page=1&limit=20`

## Evidencias recomendadas

- Primera y segunda consulta de productos mostrando `X-Cache`.
- Benchmark N+1 contra eager loading.
- Worker activo y comprobante generado.
- Estado de cola con trabajos completados.
- Respuestas paginadas para productos, pedidos y direcciones.
- Autenticacion exitosa sin mostrar tokens completos.
