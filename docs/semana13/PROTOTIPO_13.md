# Prototipo 13 — Integración móvil/backend

## 1. Objetivo
Integrar la aplicación existente con la API real, renovar credenciales y conservar datos útiles ante fallos de red. Se conservaron las pantallas y el enrutamiento de semanas anteriores.

## 2. Cliente HTTP seleccionado
Dio 5.11.1. ApiService continúa siendo la fachada consumida por controllers y AuthRepository.

## 3. Justificación
El cliente anterior centralizaba http pero no ofrecía renovación, cancelación ni reintentos. Dio permite incorporar estas responsabilidades sin reconstruir la UI. Las versiones se resolvieron con Flutter 3.44.4 y Dart 3.12.2 reales.

## 4. Configuración centralizada
mobile/lib/services/api_client.dart; instancia suministrada por apiServiceProvider. No hay Dio en pantallas. ApiConfig valida URL, origen y ambiente. No permite redirecciones de transporte ni URLs con credenciales/query/fragment.

## 5. Ambientes
API_URL y AMBIENTE son constantes de compilación, no secretos. Dev admite HTTP solo localhost, 127.0.0.1 y 10.0.2.2 en compilaciones no release. Test/staging/prod requieren HTTPS y una URL explícita del despliegue real; no se inventó un host productivo. Release prohíbe HTTP incluso si AMBIENTE=dev. Android main rechaza cleartext; la excepción 10.0.2.2 está en debug/res/xml.

## 6. Tiempos de espera
Conexión 10 s; recepción y envío 15 s. Cada GET puede sumar hasta tres esperas/reintentos; no son un timeout global.

## 7. Interceptores y orden
Autenticación/origen, logging seguro, refresh, reintentos y traducción al dominio. Véase INTERCEPTORES.md para el orden efectivo de eventos.

## 8. Renovación del token
Se utiliza POST /api/auth/refresh existente. Los dos tokens y el usuario se guardan juntos en una entrada de flutter_secure_storage. El servidor rota refresh; la sesión conserva user porque la respuesta de refresh no lo incluye. Al fallar se borra la sesión y el router bloquea rutas protegidas.

## 9. Prevención de bucles
extra.retried=true permite solo una repetición por 401; un segundo 401 termina la sesión. Hay prueba automatizada.

## 10. Renovaciones concurrentes
Future compartido single-flight. Cinco solicitudes 401 esperan una sola renovación. Un 401 tardío puede reutilizar el token nuevo. La época y la cola de escritura evitan revivir una sesión cerrada.

## 11. Serialización
Product y OrderSummary usan JsonSerializable, fromJson y toJson generados por build_runner. No se editaron .g.dart a mano. Campos opcionales null en productos; Decimal mediante conversor. OrderSummary conserva createdAt string ISO.

## 12. Tabla servidor ↔ cliente
Véase CONTRATO_API.md. La diferencia real es category.name ↔ categoryName. description está ausente del listado permitido por el backend, no es un error del serializador.

## 13. Fuente remota
ProductRemoteDataSource usa ApiService. OrderRepository reutiliza ApiService como fuente remota equivalente; no se duplicaron endpoints ni modelos.

## 14. Fuente local
ProductLocalDataSource guarda JSON del catálogo público en SharedPreferences. No contiene tokens. OrderLocalDataSource guarda un envío por cuenta en almacenamiento seguro. No había base móvil de Semana 12 que reutilizar; no se introdujo una base SQL innecesaria.

## 15. Repositorio
ProductRepository emite caché, consulta remoto, actualiza local y emite datos recientes; si falla conserva lo guardado y añade aviso. El controller consume snapshots sin decidir la política de persistencia.

## 16. Manejo de errores
Sin conexión, timeout, 4xx y 5xx tienen mensajes de dominio. 403 conserva sesión. 422 conserva el borrador y usa errors por campo. Errores SQL y cuerpos técnicos no se muestran. La cancelación intencional no aparece como error.

## 17. Reintentos
GET: conexión/timeout/5xx, máximo tres, 1/2/4 s. No se reintentan 400/403/404/409/422 ni POST por errores temporales. El reintento de POST tras 401 es seguro en este contrato porque auth rechaza antes de ejecutar el handler.

## 18. Cancelación
CancelToken en carga de catálogo; carga nueva y salida de pantalla cancelan solicitudes. Un contador descarta emisiones anteriores. La búsqueda actual filtra localmente y no necesita red.

## 19. Integración offline
Catálogo persistente con aviso de posible desactualización. Actualizar consulta nuevamente la API. La cola de pedidos hace una consulta protegida de solo lectura antes de intentar POST: si falla sin status HTTP guarda pending. Al abrir/actualizar Pedidos con red intenta una sola vez. Antes de POST persiste sending; si el resultado es incierto no lo reenvía tras reinicio o reconexión. La UI permite descartar el envío local después de revisar los pedidos. No existe idempotencia backend ni se afirma entrega exactamente una vez. No hay sincronización en segundo plano con la aplicación cerrada.

## 20. Seguridad
Sin secretos de backend en lib ni dart-define. Contraseña solo durante login/registro, nunca persistida. Tokens en almacenamiento seguro del sistema; backup Android desactivado. Headers redactados y cuerpos omitidos. Logging detallado solo dev/no release. HTTPS obligatorio en prod. .env ignorado por Git. Esto es una revisión técnica del prototipo, no una auditoría criptográfica completa.

## 21. Uso de IA
Véase USO_IA.md: asistencia en inspección, cambios y pruebas. Las decisiones de seguridad se contrastaron con el contrato y pruebas; la revisión humana final del propietario queda pendiente.

## 22. Pruebas realizadas
Suite de regresión y Semana 13 con mocks de transporte y almacenamiento. Prueba Android pública mediante flutter drive: API real, catálogo, caché persistente y escritura/lectura del plugin seguro. Véase evidence/semana13/VALIDACION.md para resultados y comandos definitivos.

## 23. Resultados
Implementación móvil y pruebas de transporte completadas. No se debe confundir refresh probado con adaptador simulado con refresh real del servidor. El usuario inició sesión manualmente y se creó un único pedido real. Se añadió diagnóstico 422 DEV y se corrigió el alcance del catch de autenticación del backend. .env no cambió. Ver RESULTADO_FINAL.md para pruebas y pendientes actuales.

## 24. Evidencias
Capturas reales en evidence/semana13; inventario y limitaciones en EVIDENCIAS.md. No se crearon imágenes para sustituir pruebas no ejecutadas. La rúbrica distingue resultados verificados de los pendientes.

Referencias: [flutter_secure_storage](https://pub.dev/documentation/flutter_secure_storage/latest/) para almacenamiento de plataforma; [json_serializable](https://pub.dev/packages/json_serializable) para generación; [Dio](https://pub.dev/documentation/dio/latest/) para interceptores y cancelación.

## Diagnóstico DEV verificado

La única creación automatizada produjo el pedido d6528596-e558-40b9-9f5f-7ac184f82d64 (Producto 1 x1, POST 201). El diagnóstico aislado copia el formulario con cantidad 0, usa OrderRepository/ApiService y recibe el 422 real. Mantiene los campos válidos y el mensaje del servidor junto a Cantidad. No utiliza outbox ni sustituye un pendiente. Solo se muestra/ejecuta en DEV/no release, probado bajo PROD.

Se corrigió el middleware de autenticación para preservar errores de ruta: await next() quedó fuera del catch de verificación. El primer ensayo reveló el fallo y cerró sesión; el ingreso manual posterior permitió comprobar POST 422 sin crear pedidos. No se cambió el esquema para producir el error.

La documentación vigente de resultados y puntaje está en RESULTADO_FINAL.md y evidence/semana13/CHECKLIST_RUBRICA.md; las descripciones técnicas previas no sustituyen la evidencia actual.
