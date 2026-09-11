# AUDITORÍA INICIAL — PROTOTIPO 13

Estado inicial: git status limpio; git diff --stat vacío.

CLIENTE HTTP: package:http 1.6, ApiService central; 8 operaciones sobre 6 rutas (categorías GET/POST, productos GET, login POST, register POST, direcciones GET, pedidos GET/POST).
AUTENTICACIÓN: AuthSession en memoria; token enviado como argumento por los controllers.
REFRESH TOKEN: backend POST /api/auth/refresh existente, JSON refreshToken; devuelve data.accessToken, refreshToken, expiresInSeconds. Rotación con revocación y hash persistido. Móvil no renueva. TTL por ACCESS_TOKEN_MINUTES (predeterminado 15); valor operativo aún sin verificar.
ALMACENAMIENTO SEGURO: no existe en móvil.
SERIALIZACIÓN: manual, Product y OrderSummary. Decimal recibido como string/número; categoría anidada. description no pertenece a los campos seleccionables del listado actual.
BASE LOCAL: no existe en móvil. PostgreSQL y Redis pertenecen al servidor.
OUTBOX: no existe; backend no implementa clave de idempotencia. No reenviar creaciones ambiguas automáticamente.
REPOSITORIOS: AuthRepository; productos y pedidos llaman ApiService desde controllers. UI no importa http.
ERRORES: ApiException y ApiErrorTranslator; 401/403/422 y campos ya implementados.
REINTENTOS: ninguno.
CANCELACIÓN: ninguna.
SEGURIDAD: tokens solo en memoria; sin logging HTTP. API_URL por compilación. Excepción HTTP Android en main debe quedar únicamente en debug. .env no versionado (solo .env.example). No leer ni publicar secretos.
CAMBIOS NECESARIOS: Dio central, credenciales seguras, refresh compartido y anti-bucle, ambientes, logging redactado, GET con backoff, cancelación, generación JSON, caché y persistencia segura de borradores de pedido sin reenvío ambiguo; pruebas y documentación.

No se requiere modificar backend ni esquema de datos. La comprobación inicial de localhost:3000 no obtuvo respuesta; se investigará el entorno antes de declarar evidencia real.
