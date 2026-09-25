# Interceptores — Semana 13

Existe un único Dio por ApiService del ProviderScope. ApiClient instala un InterceptorsWrapper con etapas explícitas; no se agregaron cinco clientes ni interceptores recursivos separados. ApiService conserva las firmas antiguas para compatibilidad: los argumentos token solo indican petición protegida, nunca construyen el header.

| Orden | Interceptor/etapa | Momento | Responsabilidad | Justificación |
|---|---|---|---|---|
| 1 | Autenticación y origen | onRequest | Verificar mismo origen, leer SecureSessionStorage, agregar Bearer, registrar época de sesión | No enviar token a otro origen ni desde una sesión obsoleta; redirecciones HTTP desactivadas |
| 2 | Logging redactado | onResponse/onError | Método, ruta conocida, status/tipo, duración; Authorization: Bearer [REDACTED] | Permite observar 401 antes de renovarlo, sin cuerpo, query, identificadores ni excepciones técnicas |
| 3 | Renovación | onResponse 401 protegido | Refresh compartido; reutilizar token ya renovado si llega un 401 tardío; retried=true | Resuelve el 401 antes de entregarlo a la UI |
| 4 | Reintentos temporales | onResponse 5xx/onError red o timeout | Solo GET, esperas 1/2/4 s, máximo tres reintentos | POST de creación no tiene idempotencia y no se repite por fallos ambiguos |
| 5 | Traducción al dominio | ApiService después de Dio | Status y JSON a ApiException; errores por campos; DioException a mensaje | UI recibe errores comprensibles, no SQL ni stack traces |

El logging se ejecuta antes del refresh para registrar cada intercambio interno, pero después de eliminar datos sensibles por construcción. Se omite siempre fuera de dev y en release, incluso si se solicita logging=true.

Refresh usa el mismo Dio con petición pública POST /api/auth/refresh. No vuelve a renovar su propio 401. _refreshing comparte Future entre solicitudes concurrentes. La petición original lleva retried=true en extra (no se transmite al servidor). Si vuelve a recibir 401 se elimina la sesión, sin bucle.

Las escrituras de credenciales se serializan. Una época identifica login/logout; una renovación tardía no vuelve a autenticar al usuario después de logout. Los reintentos de una sesión anterior se cancelan. El borrado de sesión notifica a AuthController; go_router conserva su redirección protegida a /login.

CancelToken se usa en productos; cancelar al abandonar catálogo o iniciar una carga nueva evita respuestas obsoletas. Una cancelación intencional no se convierte en error visual. Cancelar una espera de backoff no genera otro envío.

Referencias técnicas: [Dio](https://pub.dev/documentation/dio/latest/), [InterceptorsWrapper](https://pub.dev/documentation/dio/latest/dio/InterceptorsWrapper-class.html).

## Verificación real final

El diagnóstico DEV envía quantity=0 con el repositorio y cliente reales; el esquema devuelve 422. Se corrigió middleware/auth.ts para no confundir errores de ruta con autenticación inválida: el catch solo rodea verifyAccessToken, no await next(). El cliente no renueva ni cierra sesión ante el 422 corregido. Siete pruebas de backend verifican preservación de status; DEV/PROD verifican bloqueo del diagnóstico.

El fallo original sí disparó una renovación y luego cierre por anti-bucle; ese ensayo está identificado en incidencia-validacion-401.txt y no representa expiración natural.
