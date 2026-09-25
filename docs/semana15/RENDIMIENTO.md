# Rendimiento — medición pendiente de exportación DevTools

## Auditoría del 24 de septiembre de 2026, 18:49 (UTC−05)

Comprobado mediante ADB dirigido exclusivamente al equipo físico: TECNO KM4,
Android 15, API 35; proceso de DeliverPuyo activo y adb reverse TCP 3000 activo.
El backend escucha en el puerto 3000. No se detuvo la aplicación ni el backend.
Flutter local: 3.44.4, Dart 3.12.2, DevTools 2.57.0.

El propietario informa que la aplicación está en Profile y que el catálogo de
15 productos funciona con fluidez. Hay DevTools abierto y un puerto VM reenviado,
pero la consulta directa del servicio VM no estuvo disponible. Profile todavía
debe corroborarse en la sesión conectada de DevTools; no se infiere del puerto.

Android informó modo activo 1, renderFrameRate 60.0 Hz; modos admitidos:
60, 90 y aproximadamente 120 Hz. Es una lectura puntual, no la frecuencia
verificada durante un recorrido. Presupuestos: 16,67 ms a 60 Hz; 11,11 ms a
90 Hz; 8,33 ms a 120 Hz. No sumar UI y Raster para compararlos con el presupuesto:
se analiza cada etapa por separado.

| Métrica del recorrido | Estado |
|---|---|
| Duraciones UI y Raster | Sin captura |
| Total de fotogramas / lentos | No determinado; no equivale a cero |
| Percentiles y máximos | No calculables sin exportación |
| Arranque | No medido; se conserva la sesión existente |
| Antes/después | No aplica todavía: no hay problema demostrado ni corrección |

## Acción manual en la sesión existente

1. En DevTools, seleccionar el TECNO KM4 y comprobar que indique Profile.
   No utilizar la conexión del emulador.
2. Abrir **Performance** y pulsar **Record**. Según la versión, el control
   de grabación puede mostrarse como un círculo rojo.
3. En el teléfono: abrir catálogo, desplazarse, buscar un producto, abrir
   detalle, volver al catálogo y cambiar de categoría si está disponible.
4. Pulsar **Stop** y luego **Export**, arriba a la derecha del gráfico de frames.
5. Mantener la exportación original local fuera del repositorio hasta revisar
   URLs, tokens, datos personales e identificadores. Preparar después una copia
   sanitizada en evidence/semana15/. No incluir la URL privada de conexión VM.
6. Registrar frecuencia durante el recorrido, fecha, duración y condiciones.
   Inspeccionar frames lentos y sus duraciones UI/Raster. UI representa trabajo
   Dart/construcción de interfaz; Raster, rasterización/renderizado.

Fuente: https://docs.flutter.dev/tools/devtools/performance

No se aplican optimizaciones a ciegas. Si no se observa un problema en una captura
válida, se documentará ese resultado y quedará sin justificar el requisito de
corrección y comparación antes/después. Por ahora no se puede afirmar ese resultado.

## Procedimiento histórico (no ejecutarlo para reemplazar la sesión activa)

ACCIÓN MANUAL REQUERIDA — PRUEBA DE RENDIMIENTO EN DISPOSITIVO FÍSICO

No se ejecutó modo profile ni se midieron arranque, fluidez, frames, hilo UI o raster. El emulador utilizado para integración no sirve como evidencia de rendimiento del encargo. Los tiempos impresos por flutter test y Gradle no son métricas de la aplicación.

Cuando el usuario disponga del equipo físico, identificarlo con `flutter devices` y ejecutar desde mobile:

```text
flutter run --profile -d <DEVICE_ID> --dart-define=AMBIENTE=prod --dart-define=API_URL=<URL_HTTPS_REAL>
```

Los valores entre ángulos son parámetros pendientes, no credenciales ni una configuración ya probada. No se debe usar la URL sintética de los tests para esta medición.

Registrar modelo, SO, versión de app, condiciones y trazas DevTools del arranque y del flujo login/catálogo/pedido; separar tiempos UI/raster y frames lentos. Si se identifica un problema real, guardar el antes, corregir únicamente su causa y volver a medir bajo las mismas condiciones. No se ha realizado ninguna optimización a ciegas ni se atribuye una mejora sin medición.
