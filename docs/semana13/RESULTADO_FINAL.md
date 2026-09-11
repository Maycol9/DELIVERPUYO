# RESULTADO FINAL — PROTOTIPO 13 DELIVERPUYO

Estado: implementación móvil y verificación pública completadas; demostración autenticada real pendiente de login manual. No se declara cumplimiento total del taller.

## AUDITORÍA INICIAL
- Cliente anterior: package:http centralizado en ApiService.
- Persistencia local: no existía.
- Secure storage: no existía.
- Outbox: no existía.
- Refresh existente: sí, POST /api/auth/refresh en backend; móvil no lo consumía.
- Informe previo a cambios: AUDITORIA_INICIAL.md.

## CLIENTE HTTP
- Cliente: Dio 5.11.1; instancia única por apiServiceProvider/ProviderScope.
- Archivo: mobile/lib/services/api_client.dart; fachada api_service.dart.
- baseUrl: API_URL por compilación; desarrollo Android http://10.0.2.2:3000.
- connectTimeout: 10 segundos; receiveTimeout y sendTimeout: 15 segundos.
- validateStatus: 200 <= status < 600; ApiService interpreta errores de dominio.

## AMBIENTES
- dev: HTTP únicamente local, no release; logging redactado.
- staging/test: API HTTPS explícita; logging detallado desactivado.
- prod: HTTPS obligatorio y logging detallado desactivado; probado con configuración prod y transporte simulado.
- Release rechaza HTTP incluso con ambiente dev. La excepción Android vive en src/debug.

## INTERCEPTORES
1. Autenticación y protección de origen en onRequest.
2. Logging por intento sin cuerpos ni query, con Authorization redactado.
3. Refresh antes de entregar un 401 protegido al consumidor.
4. Reintentos temporales de GET.
5. Traducción de respuesta/excepción al dominio en ApiService.

Implementación mediante etapas de un InterceptorsWrapper; orden y justificación en INTERCEPTORES.md.

## AUTENTICACIÓN
- Secure storage: flutter_secure_storage 11.1.0; tokens/usuario en un registro cifrado por la plataforma.
- Token automático: leído desde SessionStorage en peticiones protegidas; sin headers manuales en pantallas.
- Authorization: Bearer [REDACTED] en logging.
- Restauración: main espera lectura de sesión antes del primer enrutamiento; logout la elimina.

## REFRESH
- Endpoint real: POST /api/auth/refresh.
- 401 detectado, renovación y petición reintentada: implementados y probados con adaptador fake.
- Anti-bucle: extra.retried=true; segundo 401 cierra sesión.
- Concurrencia: cinco peticiones, una sola renovación; Future compartido.
- Fallo: limpia almacenamiento y AuthSession; router redirige rutas protegidas a login.
- Protección adicional: época de sesión y escrituras serializadas frente a logout durante refresh.
- Prueba autenticada real y TTL operativo: pendientes; TTL predeterminado del código 15 minutos, sin modificar .env.

## SERIALIZACIÓN
- Entidades: Product y OrderSummary.
- Generación: json_serializable/build_runner; archivos .g.dart generados, no escritos manualmente.
- Opcionales: imageUrl, description y categoryName null admitidos.
- Divergencia real: category.name ↔ categoryName; resto conserva nombres. Decimal string/número convertido a double.
- createdAt mantiene String ISO por compatibilidad con pantallas actuales.

## CAPA DE DATOS
- Remota: ProductRemoteDataSource y ApiService reutilizado para pedidos.
- Local: ProductLocalDataSource (SharedPreferences solo datos públicos) y OrderLocalDataSource (envío cifrado por cuenta).
- Repositorios: ProductRepository, OrderRepository y AuthRepository existente.
- UI: sin importaciones Dio/http; controllers median los flujos.

## ERRORES
- Sin conexión: mensaje comprensible; catálogo guardado y aviso.
- Timeout: mensaje de servidor demorado.
- 4xx: 401 gestionado, 403 conserva sesión, 404/409 traducidos, 422 por campo.
- 5xx: mensaje temporal sin contenido SQL o cuerpos técnicos.
- 422 probado en controller y formulario real mediante fake; captura de backend protegido pendiente.

## REINTENTOS
- GET: máximo tres reintentos por conexión, timeout o 5xx.
- POST: no se repite por errores de red/5xx; sí una repetición tras 401 autenticado antes del handler.
- Backoff: 1, 2, 4 segundos; cancelable.
- Idempotencia backend: no existe; no se inventaron claves UUID ni garantía exactamente una vez.

## CANCELACIÓN
- Implementada: CancelToken en carga de productos.
- Flujo: abandonar catálogo/iniciar otra carga; contador descarta emisiones viejas; cancelación sin error visual.

## OFFLINE
- Caché: persistente y verificada en Android.
- Datos visibles sin red: sí; captura 10 muestra modo avión, producto y aviso.
- Outbox: una operación por usuario, pending solo antes de intentar POST; sending impide repetir un resultado incierto.
- Reconexión: catálogo vuelve a remoto; pendiente de pedido se intenta al abrir/actualizar Pedidos.
- Cola probada con fakes: persistencia, aislamiento de cuentas, reconexión y no repetición de POST ambiguo.
- Límite: sin tarea en segundo plano; para preparar un pedido offline se necesitan los datos del formulario cargados previamente. No se creó pedido real para demostrar outbox.

## SEGURIDAD
- Secretos hardcodeados de backend en lib: no encontrados.
- Tokens cifrados: mecanismo nativo de flutter_secure_storage; escritura/lectura del plugin real verificada.
- Contraseña persistida: no.
- Logging prod: desactivado y probado.
- HTTPS prod: obligatorio y probado.
- .env versionado: no; continúa ignorado. No se modificó.
- Copia de seguridad Android: desactivada para evitar respaldos de credenciales.

## PRUEBA REAL
- Login: formulario capturado; autenticación exitosa pendiente de intervención manual.
- Productos: GET 200, success=true, 15 productos.
- Creación: no ejecutada; cero registros creados.
- Refresh: pendiente en backend real; pruebas fake aprobadas.
- 422: pendiente en backend protegido; tests de dominio/widget aprobados.
- Offline: verificado en Android.
- Reconexión: verificada, GET 200, aviso retirado; avión=0, Wi-Fi=1, datos=1.

## PRUEBAS
- build_runner: correcto. El generador instalado ignora --delete-conflicting-outputs porque fue retirado.
- Formato: dart format . encontró una ruta transitoria de build/; formato de todas las fuentes completado con lib test integration_test test_driver.
- flutter analyze: No issues found!
- flutter test: 68 aprobadas, 1 omitida condicionada a prod.
- Prueba prod separada: 1 aprobada.
- Prueba funcional Android pública: 1 caso aprobado; +2 del driver incluye tearDownAll.
- Total: 69 casos unitarios/widget únicos aprobados más 1 funcional Android público. Los 28 anteriores se conservan.

## EVIDENCIAS
- 01_login.png: disponible (formulario, no login exitoso).
- 02_productos_backend_real.png: disponible.
- 03_creacion_registro.png: pendiente.
- 04_registro_creado.png: pendiente.
- 05_refresh_token_antes.png: pendiente.
- 06_refresh_token_exitoso.png: pendiente.
- 07_error_422.png: pendiente.
- 08_error_campo_422.png: pendiente.
- 09_online_catalogo.png: disponible.
- 10_offline_catalogo_cache.png: disponible.
- 11_sincronizacion_reconexion.png: disponible (catálogo, no pedido).
- 12_seguridad_configuracion.png: disponible (panel real de resultados de prueba).

Inventario: evidence/semana13/EVIDENCIAS.md. Salidas reales: flutter-analyze.txt, flutter-test.txt, backend-products.json.

## DOCUMENTACIÓN
- CONTRATO_API.md: creado.
- INTERCEPTORES.md: creado.
- PROTOTIPO_13.md: creado, 24 apartados.
- USO_IA.md: creado.
- GUIA_VIDEO.md: creada, 20 pasos.
- CHECKLIST_RUBRICA.md: creado en evidence/semana13.
- Adicionales: AUDITORIA_INICIAL.md, SEGURIDAD_VERIFICACION.md, VALIDACION.md e inventario de capturas.

## RÚBRICA ESTIMADA
- Cliente: 1.0/1.0.
- Autenticación: 1.0/1.5.
- Renovación: 1.5/2.5.
- Serialización: 1.5/1.5.
- Capa de datos: 1.0/1.5.
- Errores/reintentos: 1.5/1.5.
- Seguridad: 0.5/0.5.
- TOTAL: 8.0/10; potencial 10/10 sujeto a completar demostración autenticada y evaluación docente.

## BASE DE DATOS MODIFICADA
Ningún pedido, usuario, dirección ni refresh token creado por estas pruebas públicas. No se ejecutaron migraciones ni seed. Los GET pueden poblar la caché Redis existente.

## BACKEND MODIFICADO
Ningún cambio funcional. Se inició Next.js local; su ajuste automático de next-env.d.ts se restauró. No se alteraron rutas, validaciones, contratos ni TTL.

## GIT
- git status y git diff --stat revisados.
- git diff --check: sin errores de whitespace; advertencias Windows LF/CRLF.
- .env, build/, .dart_tool/, node_modules/ y logs locales ignorados.
- commit: NO; push: NO; git add: NO.

## PENDIENTES MANUALES
Iniciar sesión directamente en el emulador sin compartir secretos. Después completar como máximo un pedido válido, 422 protegido seguro y expiración/refresh real; documentar ID, TTL efectivo y seis capturas faltantes. No volver a ejecutar un POST de resultado incierto. Grabar el video siguiendo GUIA_VIDEO.md.

La revisión automática rechazó el auxiliar propuesto porque transfería credenciales y derivados del secreto JWT a un proceso de prueba. No se ejecutó ni se creó; se continuó con la alternativa pública sin secretos. El motivo y el procedimiento seguro están documentados en SEGURIDAD_VERIFICACION.md.
