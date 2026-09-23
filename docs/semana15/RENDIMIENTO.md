# Rendimiento pendiente

ACCIÓN MANUAL REQUERIDA — PRUEBA DE RENDIMIENTO EN DISPOSITIVO FÍSICO

No se ejecutó modo profile ni se midieron arranque, fluidez, frames, hilo UI o raster. El emulador utilizado para integración no sirve como evidencia de rendimiento del encargo. Los tiempos impresos por flutter test y Gradle no son métricas de la aplicación.

Cuando el usuario disponga del equipo físico, identificarlo con `flutter devices` y ejecutar desde mobile:

```text
flutter run --profile -d <DEVICE_ID> --dart-define=AMBIENTE=prod --dart-define=API_URL=<URL_HTTPS_REAL>
```

Los valores entre ángulos son parámetros pendientes, no credenciales ni una configuración ya probada. No se debe usar la URL sintética de los tests para esta medición.

Registrar modelo, SO, versión de app, condiciones y trazas DevTools del arranque y del flujo login/catálogo/pedido; separar tiempos UI/raster y frames lentos. Si se identifica un problema real, guardar el antes, corregir únicamente su causa y volver a medir bajo las mismas condiciones. No se ha realizado ninguna optimización a ciegas ni se atribuye una mejora sin medición.
