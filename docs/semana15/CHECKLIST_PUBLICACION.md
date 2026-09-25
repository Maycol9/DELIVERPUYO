# Checklist de prepublicación

Este checklist distingue verificado de pendiente; no autoriza publicación.

## Pruebas

- [x] Unitarias: autenticación, validación, outbox y HTTP.
- [x] Interfaz: catálogo loading/data/empty/error y formulario inválido; se conserva 422.
- [x] Un E2E crítico: aprobado en emulador Android API 36 con transporte controlado.
- [x] Cobertura generada y rama de restore fallido añadida.
- [x] Ninguna prueba nueva desactivada. La única omisión condicional previa de PROD fue ejecutada aparte y aprobada.

## UI

- [x] Loading: indicador y mensaje.
- [x] Data: productos.
- [x] Empty: catálogo vacío.
- [x] Error: mensaje y reintento con recuperación.

## Rendimiento

- [ ] Modo Profile corroborado en DevTools (informado por el propietario).
- [x] TECNO KM4 físico conectado, Android 15/API 35, comprobado por ADB el 24/09/2026.
- [ ] Arranque, frames lentos, hilo UI y raster.
- [ ] Problema real identificado, corregido y vuelto a medir.

## Seguridad

- [x] Almacenamiento seguro y tokens en peticiones protegidas: tests existentes aprobados.
- [x] Logs del alcance móvil sin datos sensibles: filtros previos y nuevo esquema cerrado probados.
- [x] SDK Sentry 9.30.1 integrado, filtros locales y botón manual probados.
- [ ] Archivar revisión de privacidad del evento remoto y captura sanitizada.

## Monitoreo

- [x] Servicio configurado por el propietario; no se registra el DSN.
- [x] Recepción real de StateError confirmada por el propietario.
- [x] Traza, ambiente dev y versión 1.0.0 (1) confirmados por el propietario.
- [ ] Evidencia visual sanitizada del panel archivada (no aportada).

## Publicación

- [x] flutter analyze limpio.
- [x] Cierre 24/09/2026: flutter test y flutter test --coverage, 132 aprobadas y 1 omitida condicionalmente en DEV; cero fallos. Cobertura de líneas: 1512/2227 = 67,89 %. La prueba PROD requiere `AMBIENTE=prod` y `API_URL` HTTPS sintética.
- [x] Compilación debug exitosa en TEMP en la etapa anterior. No se recompiló durante la medición. No publicar APK con DSN.
- [x] Configuración release inspeccionada.
- [ ] Firma de release: actualmente usa signingConfigs.debug, no lista para publicar.
- [ ] API_URL HTTPS y ambiente prod definidos para la compilación de publicación. Los valores por defecto son DEV/HTTP local.
- [ ] Workflow ejecutado en GitHub: creado localmente, sin commit/push.

No se modificaron credenciales, firma, .env, backend ni base de datos. Compilar debug no valida una publicación release.

## Revisión de entrega del 24/09/2026

- [x] Formato: 75 archivos, 0 cambios; analyze y diff --check sin errores.
- [x] Evidencias actuales: archivos *-cierre.txt y lcov-cierre.info.
- [x] Se sustituyeron rutas personales por marcadores en seis logs históricos.
- [x] Workflow local incluye flutter analyze, flutter test --coverage y pruebas PROD.
- [ ] Captura física de Performance exportada y analizada, con frecuencia durante el recorrido.
- [ ] Resultado de GitHub Actions remoto: no consultado ni ejecutado en esta sesión.

Subir únicamente fuentes/pruebas revisadas, documentación y evidencias sanitizadas.
Excluir .env, credenciales, DSN, URLs privadas de VM, build, .dart_tool, .gradle,
APK, logs sin revisar y exportaciones originales que contengan información personal.
