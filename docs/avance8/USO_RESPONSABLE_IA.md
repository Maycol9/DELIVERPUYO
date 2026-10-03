# Uso Responsable De Inteligencia Artificial

## Herramienta utilizada

Se utilizo ChatGPT/Codex como herramienta de apoyo para auditar, revisar, corregir y documentar el backend DeliverPuyo.

## Finalidad

- Revisar cumplimiento del Avance 8.
- Detectar riesgos de seguridad, rendimiento y documentacion.
- Corregir problemas seguros sin alterar datos ni migraciones.
- Preparar documentacion tecnica universitaria.
- Verificar comandos de validacion del proyecto.

## Consultas realizadas

- Auditoria de endpoints `GET /api/products`, `GET /api/orders`, `GET /api/orders/{id}`, `POST /api/orders`, `POST /api/auth/login`, `POST /api/auth/refresh` y `GET /api/addresses`.
- Revision de cache Redis, N+1, eager/lazy loading, BullMQ, JWT, Zod, Docker Compose y evidencias.
- Busqueda de referencias residuales a proyectos ajenos.
- Revision de secretos versionados y archivos ignorados.

## Archivos revisados

- `package.json`
- `README.md`
- `.gitignore`
- `.env.example`
- `docker-compose.yml`
- `next.config.ts`
- `prisma/schema.prisma`
- `services/*`
- `pages/api/*`
- `lib/*`
- `middleware/*`
- `validations/*`
- `workers/receipt.worker.ts`
- `scripts/*`
- `evidence/*`
- `spec/avance8/*`

## Cambios propuestos y aplicados

- Correccion de referencia residual a un proyecto externo.
- Paginacion consistente en pedidos y direcciones.
- Validacion UUID en rutas dinamicas.
- Estado `BYPASS` para cache omitido intencionalmente.
- Conservacion de `evidence/benchmark-results.json`.
- Creacion de documentacion formal de Avance 8.

## Forma de verificacion

Cada propuesta debe verificarse ejecutando comandos locales no destructivos:

```powershell
npx prisma format
npx prisma validate
npx prisma generate
npm run typecheck
npm run build
```

Cuando PostgreSQL y Redis esten disponibles:

```powershell
docker compose ps
docker compose exec -T redis redis-cli ping
npm run benchmark
npx tsx --env-file=.env scripts/check-queue.ts
```

## Responsabilidad del estudiante

La IA fue una herramienta de apoyo. La revision final, ejecucion en el entorno local, seleccion de evidencias, grabacion del video y entrega academica son responsabilidad del estudiante. Las metricas documentadas corresponden a resultados reales conservados en `evidence/benchmark-results.json`; no deben reemplazarse por estimaciones.
