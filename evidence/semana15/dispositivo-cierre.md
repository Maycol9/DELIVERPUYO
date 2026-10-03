# Auditoría física — 2026-09-24 18:49 UTC−05

- ADB dirigido al dispositivo físico: TECNO KM4, conectado.
- Android 15, API 35. Proceso de DeliverPuyo activo.
- adb reverse TCP 3000 activo; backend escuchando en puerto 3000.
- Android dumpsys display: modo activo 1, renderFrameRate 60.0 Hz.
- Modos disponibles: 60, 90 y aproximadamente 120 Hz.
- No se guarda número de serie, PID, URL de VM ni identificadores de sesión.
- Profile: comunicado por el propietario, pendiente corroborar en DevTools.
- DevTools abierto; acceso directo a VM no disponible en la consulta realizada.
- Recorrido todavía sin registrar: catálogo, scroll, búsqueda, detalle, regreso,
  cambio de categoría. No hay tiempos UI/Raster ni número de frames lentos.

La lectura puntual de frecuencia no demuestra la frecuencia durante el recorrido.
No se detuvieron sesiones, no se reinició backend y no se modificó código de rendimiento.
