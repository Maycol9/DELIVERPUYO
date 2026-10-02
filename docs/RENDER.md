# Despliegue del backend en Render

## Servicio web

- Crear un servicio **Web Service** desde el repositorio, con raíz del proyecto en `.`.
- Usar Node.js 22 o superior.
- **Build Command:** `npm ci && npm run generate && npm run build`
- **Start Command:** `npm start`
- Render proporciona `PORT`; `next start` lo utiliza automáticamente.
- Configurar las variables requeridas durante el build y en runtime. No subir `.env` ni copiar secretos a este documento.

## Variables de entorno

Requeridas por el backend:

- `DATABASE_URL`: URL PostgreSQL de producción.
- `REDIS_URL`: URL Redis de producción; el esquema actual también la exige cuando `QUEUE_ENABLED=false`.
- `JWT_ACCESS_SECRET`: secreto aleatorio de al menos 32 caracteres.
- `JWT_REFRESH_SECRET`: secreto aleatorio distinto, de al menos 32 caracteres.

Configurar además:

- `NODE_ENV=production`
- `QUEUE_ENABLED=false` hasta que el worker de comprobantes esté desplegado; cambiar a `true` solo cuando Redis y el worker estén operativos.
- `ENABLE_BENCHMARK_ENDPOINTS=false`
- `CORS_ALLOWED_ORIGINS`: orígenes HTTPS exactos de Flutter Web, separados por comas. No incluir rutas ni usar `*`. Puede omitirse si solo se consume desde Flutter móvil nativo.

Los valores de secretos deben generarse y guardarse en el panel de Render; no usar los valores ficticios de `.env.example`.

## Base de datos

Crear primero una base PostgreSQL administrada y configurar `DATABASE_URL`. Antes del primer despliegue, ejecutar una vez contra esa base:

```sh
npx prisma migrate deploy
```

No ejecutar `prisma migrate dev` en producción. Este repositorio contiene la migración inicial en `prisma/migrations/`.

## Redis y comprobantes

El servicio web puede iniciar sin arrancar el worker. Con `QUEUE_ENABLED=false`, crear pedidos no encola comprobantes. Redis continúa siendo necesario para satisfacer la configuración actual y para el caché de productos.

Para procesar comprobantes, crear un servicio **Background Worker** separado con el mismo repositorio, Node.js 22+, las mismas variables de entorno y comando:

```sh
npm run worker:receipt
```

El worker escribe PDFs en `storage/receipts`, que no es almacenamiento durable en un filesystem efímero. Para conservar comprobantes, configurar un disco persistente o adaptar el almacenamiento a un object storage antes de depender de ellos en producción.

## CORS y Flutter

Flutter móvil nativo no aplica la política CORS del navegador. Flutter Web sí requiere que el origen exacto de su sitio esté en `CORS_ALLOWED_ORIGINS`. En desarrollo se permiten `http://localhost:8081` y `http://127.0.0.1:8081`; producción no permite esos orígenes automáticamente. Se autorizan `GET`, `POST`, `PATCH` y preflight `OPTIONS`.

Compilar la app Flutter de producción con la URL pública HTTPS del backend y `AMBIENTE=prod`, por ejemplo usando `--dart-define=API_URL=https://<dominio-del-backend>` y `--dart-define=AMBIENTE=prod`.
