# Rendimiento — medición física con Flutter DevTools

## Medición del 25 de septiembre de 2026

Comprobado mediante ADB dirigido exclusivamente al equipo físico: TECNO KM4,
Android 15, API 35; proceso de DeliverPuyo activo y adb reverse TCP 3000 activo.
El backend escucha en el puerto 3000. No se detuvo la aplicación ni el backend.
Flutter local: 3.44.4, Dart 3.12.2, DevTools 2.57.0.

La sesión conectada a DevTools confirmó `Flutter native`, `Profile build`, Android
arm64 y motor Impeller. La captura se realizó sobre la aplicación existente, sin
recompilarla ni detener el backend.

Android informó `mActiveRenderFrameRate=60.0` durante la medición; el dispositivo
admite 60, 90 y aproximadamente 120 Hz. El presupuesto usado fue 16,67 ms por
fotograma a 60 Hz. UI y Raster se analizaron por separado, sin sumarlos.

| Métrica del recorrido | Resultado real |
|---|---|
| Duraciones UI y Raster | UI máxima 3,8 ms; Raster máxima 12,4 ms |
| Total de fotogramas / lentos | 26 registrados; 0 lentos/jank |
| FPS promedio | 59 FPS según DevTools |
| Frecuencia efectiva | 60 Hz durante la sesión; 90/120 Hz admitidos |
| Acción relacionada con frames lentos | Ninguna: DevTools indicó “no jank detected” |

## Recorrido y análisis

Se ejecutaron desplazamientos repetidos del catálogo, búsqueda de producto,
apertura del detalle, regreso al catálogo y cambio de categoría. Se registraron
26 fotogramas. El mayor tiempo UI fue 3,8 ms y el mayor Raster 12,4 ms, ambos por
debajo del presupuesto de 16,67 ms a 60 Hz. No se detectó un problema atribuible
al hilo UI ni al renderizado Raster, por lo que no se modificó el código Flutter.

La evidencia sanitizada está en
`evidence/semana15/performance-profile-2026-09-25.json`. La exportación original
`dart_devtools_2026-09-25_10_48_20.820.json` se conserva fuera del repositorio.

## Procedimiento ejecutado en la sesión existente

1. En DevTools, seleccionar el TECNO KM4 y comprobar que indique Profile.
   No utilizar la conexión del emulador.
2. Abrir **Performance**, limpiar la captura previa e iniciar la grabación.
3. En el teléfono: abrir catálogo, desplazarse, buscar un producto, abrir
   detalle, volver al catálogo y cambiar de categoría si está disponible.
4. Detener la grabación y usar **Save this screen's data for offline viewing**.
5. Mantener la exportación original local fuera del repositorio hasta revisar
   URLs, tokens, datos personales e identificadores. Preparar después una copia
   sanitizada en evidence/semana15/. No incluir la URL privada de conexión VM.
6. Registrar frecuencia durante el recorrido, fecha, duración y condiciones.
   Inspeccionar frames lentos y sus duraciones UI/Raster. UI representa trabajo
   Dart/construcción de interfaz; Raster, rasterización/renderizado.

Fuente: https://docs.flutter.dev/tools/devtools/performance

No se aplican optimizaciones a ciegas. Esta captura válida no demuestra un
problema de fluidez, por lo que no se realizó una corrección ni una comparación
antes/después.

## Procedimiento histórico (no ejecutarlo para reemplazar la sesión activa)

REGISTRO HISTÓRICO — PROCEDIMIENTO ANTERIOR A LA MEDICIÓN DEL 25/09/2026

Este bloque conserva el procedimiento previo y no describe el estado actual. El
emulador utilizado para integración no sirve como evidencia de rendimiento del
encargo. Los tiempos impresos por flutter test y Gradle no son métricas de la
aplicación; la medición física actual está documentada arriba.

Cuando el usuario disponga del equipo físico, identificarlo con `flutter devices` y ejecutar desde mobile:

```text
flutter run --profile -d <DEVICE_ID> --dart-define=AMBIENTE=prod --dart-define=API_URL=<URL_HTTPS_REAL>
```

Los valores entre ángulos son parámetros pendientes, no credenciales ni una configuración ya probada. No se debe usar la URL sintética de los tests para esta medición.

Registrar modelo, SO, versión de app, condiciones y trazas DevTools del arranque y del flujo login/catálogo/pedido; separar tiempos UI/raster y frames lentos. Si se identifica un problema real, guardar el antes, corregir únicamente su causa y volver a medir bajo las mismas condiciones. No se ha realizado ninguna optimización a ciegas ni se atribuye una mejora sin medición.
