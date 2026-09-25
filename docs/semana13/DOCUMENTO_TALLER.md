# Taller Semana 13 — Integración móvil y backend

DeliverPuyo usa Flutter con Next.js, PostgreSQL y Redis. Este documento describe lo implementado; los resultados reales y límites están en RESULTADO_FINAL.md y en el índice de evidencias.

## Cliente y configuración

1. **Cliente HTTP:** Dio, centralizado en ApiClient y expuesto mediante ApiService.
2. **Justificación:** permite autenticación, cancelación, timeouts y recuperación de solicitudes en un mismo transporte.
3. **Instancia:** apiServiceProvider comparte una instancia por ProviderScope; las pantallas no crean clientes HTTP.
4. **Ambientes:** API_URL y AMBIENTE se definen al compilar. Android DEV usa http://10.0.2.2:3000; staging/test/prod exigen una URL HTTPS explícita. No se pasan secretos por dart-define.
5. **connectTimeout:** 10 segundos.
6. **receiveTimeout:** 15 segundos; sendTimeout también 15 segundos.

## Interceptores y sesión

7. **Etapas:** protección de origen, autenticación, logging limitado, refresh, reintento temporal y traducción de errores.
8. **Orden:** onRequest valida origen y agrega la sesión en rutas protegidas; onResponse registra estado, resuelve 401 y luego evalúa 5xx; onError trata fallos de transporte. ApiService traduce la respuesta para la UI. Son etapas de InterceptorsWrapper, no cinco clientes distintos.
9. **Refresh:** ante un 401 protegido, POST /api/auth/refresh renueva la sesión y se reintenta la petición. Los valores se conservan dentro de la app y su almacenamiento seguro.
10. **Anti-bucle:** retried permite una sola renovación/repetición por solicitud. Un segundo 401 o refresh fallido cierra la sesión. Se verifica con pruebas automatizadas.
11. **Concurrencia:** un Future compartido agrupa renovaciones simultáneas. Cinco peticiones concurrentes producen una renovación en la prueba.

## Modelos

12. **Correspondencia servidor ↔ cliente:**

| Servidor | Cliente | Conversión |
|---|---|---|
| Product.id/name | Product.id/name | String |
| Product.price | Product.price | Decimal string o número → double |
| Product.stock | Product.stock | número/string → int |
| Product.category.name | Product.categoryName | objeto anidado → String? |
| Product.imageUrl/description | mismo nombre | ausente/null → null |
| Order.id/status | OrderSummary.id/status | String |
| Order.total | OrderSummary.total | Decimal → double |
| Order.createdAt | OrderSummary.createdAt | ISO 8601 conservado como String |

13. **Product:** representa catálogo y caché; categoryName es una proyección, no una categoría completa.
14. **Order:** OrderSummary representa id, estado, total y fecha. No pretende incluir todos los campos de la entidad Prisma.
15. **Generación:** json_serializable genera product.g.dart y order.g.dart; JsonKey documenta conversiones y nullables. El detalle completo está en CONTRATO_API.md.

## Datos y fallos

16. **Remota:** ProductRemoteDataSource consulta ApiService; pedidos usan ApiService desde OrderRepository.
17. **Local:** SharedPreferences guarda catálogo público; OrderLocalDataSource conserva outbox cifrada por cuenta. La sesión usa SecureSessionStorage.
18. **Repositorio:** ProductRepository elige caché/remoto; OrderRepository coordina envío y persistencia. Los controllers entregan estados a la UI, que no conoce Dio.
19. **Cuatro familias:** sin conexión, timeout, errores 4xx y fallos 5xx tienen mensajes de dominio. El 422 conserva los mensajes por campo del backend, sin mostrar JSON o stack traces.
20. **Reintentos:** GET admite tres reintentos temporales con esperas de 1, 2 y 4 segundos. POST no se repite por fallos de red/5xx; puede repetirse una vez tras un 401 de autenticación anterior al handler. No existe idempotencia de servidor ni garantía de entrega exactamente una vez.
21. **Cancelación:** CancelToken cancela carga del catálogo al salir o reemplazar una solicitud; el controller descarta respuestas viejas.
22. **Offline:** catálogo persistente y aviso de datos guardados. Outbox registra pending antes de un POST no intentado y sending antes de enviarlo; un resultado ambiguo no se reenvía automáticamente. Sin tarea de sincronización en segundo plano. Outbox completo se prueba con fakes; no se presenta como una segunda creación real.

## Seguridad y evidencia

23. **Seguridad:** no persistir contraseña; sesión cifrada por plataforma; logs sin cuerpos, query ni valores de autenticación. La revisión del seed expuso accidentalmente credenciales de prueba en una salida previa: no se reproducen aquí ni se usan para acceder. No se afirma una auditoría de seguridad sin incidentes.
24. **HTTPS:** obligatorio en PROD, staging/test y release; HTTP solo DEV local autorizado.
25. **Logging:** detallado únicamente DEV/no release. Test PROD verifica que permanece desactivado incluso si se solicita.
26. **Evidencias:** evidence/semana13/INDICE_EVIDENCIAS.md enumera las doce capturas y sus límites. Los logs redactados y pruebas complementan las imágenes; ninguna captura aislada demuestra por sí sola la renovación.

## Diagnóstico DEV y corrección necesaria

El botón “Probar validación backend 422 (DEV)” conserva los validadores normales. Con un formulario válido envía por el repositorio una copia con cantidad 0, que el esquema real rechaza. No toca outbox ni sustituye un pendiente; conserva dirección, producto y cantidad visibles. El error aplanado `items` se muestra junto a Cantidad porque ese es el único campo alterado por el diagnóstico. Widget y repositorio están bloqueados fuera de DEV/no release, con pruebas PROD de ausencia y cero solicitudes.

La prueba descubrió que middleware/auth.ts convertía errores de las rutas en 401 porque await next() estaba dentro del catch de verificación. Se movió fuera: los 422/403/409/500 mantienen su estado y detalles. No se cambió el esquema para fabricar una respuesta. Siete pruebas ejecutan el middleware real con verificación simulada, sin claves, tokens reales ni base de datos.
