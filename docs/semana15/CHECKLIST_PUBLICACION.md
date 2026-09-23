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

- [ ] Modo profile.
- [ ] Dispositivo físico.
- [ ] Arranque, frames lentos, hilo UI y raster.
- [ ] Problema real identificado, corregido y vuelto a medir.

## Seguridad

- [x] Almacenamiento seguro y tokens en peticiones protegidas: tests existentes aprobados.
- [x] Logs del alcance móvil sin datos sensibles: filtros previos y nuevo esquema cerrado probados.
- [ ] Monitoreo remoto filtrado: sin SDK configurado todavía.

## Monitoreo

- [ ] Servicio configurado con cuenta/DSN real.
- [ ] Fallo controlado recibido en consola.
- [ ] Stack trace y versión comprobados.

## Publicación

- [x] flutter analyze limpio.
- [x] flutter test --coverage: 98 aprobadas y 1 omitida condicionalmente en DEV; la prueba PROD se ejecuta con `AMBIENTE=prod` y `API_URL` HTTPS sintética.
- [x] flutter build apk --debug compila.
- [x] Configuración release inspeccionada.
- [ ] Firma de release: actualmente usa signingConfigs.debug, no lista para publicar.
- [ ] API_URL HTTPS y ambiente prod definidos para la compilación de publicación. Los valores por defecto son DEV/HTTP local.
- [ ] Workflow ejecutado en GitHub: creado localmente, sin commit/push.

No se modificaron credenciales, firma, .env, backend ni base de datos. Compilar debug no valida una publicación release.
