# Validación — Semana 13

Resultados vigentes en docs/semana13/RESULTADO_FINAL.md e INDICE_EVIDENCIAS.md. No se mezclan ejecuciones simuladas con llamadas reales.

| Verificación | Resultado |
|---|---|
| Formato lib/test | 52 archivos, 0 cambios al cierre |
| Flutter analyze | Sin problemas |
| DEV | 70 aprobadas, 1 omitida condicionada a PROD |
| PROD | 3 aprobadas; diagnóstico ausente/bloqueado y logging desactivado |
| Backend auth | 7 aprobadas; status de ruta preservado |
| TypeScript | npm run typecheck correcto |
| Creación real | POST 201, d6528596-e558-40b9-9f5f-7ac184f82d64, Producto 1 x1, $4,00 |
| 422 real | POST 422, cantidad 0 enviada por diagnóstico DEV; mensaje junto a Cantidad; formulario conserva cantidad 1 |
| Conteo en diagnóstico corregido | 29 antes / 29 después, cero creación accidental |
| Refresh anterior | GET 401, una renovación, retry GET 200, sesión conservada |
| Anti-bucle/concurrencia | PASS; cinco peticiones, una renovación |
| Offline/reconexión | Evidencia histórica real de 15 productos y GET 200 conservada |
| Android automatizado | 1 caso público anterior; no se reinstaló/reinició la app en este cierre |

La automatización envió un único pedido válido (conteo 27→28). Apareció otro pedido después fuera de esa acción (conteo 29); su origen no está confirmado. La prueba 422 no creó registros. Primer ensayo inválido expuso el bug de middleware y cerró sesión; login manual posterior observado. No se oculta esa incidencia.

73 ejecuciones Flutter aprobadas entre DEV/PROD (dos casos ejecutados en ambos ambientes), más siete pruebas backend. No sumar el caso omitido ni la integración histórica como ejecuciones actuales.

Logs: final-flutter-analyze.txt, final-flutter-test.txt, final-flutter-prod.txt, final-backend-auth-test.txt, cierre-final-http.txt, 422-http-real.txt, 422-conteo-pedidos.txt, incidencia-validacion-401.txt, refresh-antes-http.txt. La correlación de refresh natural actual se añadirá al terminar.
