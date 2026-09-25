# Evidencias Semana 15

Salidas de comandos ejecutados durante la implementación. Los fallos previos a una corrección se conservan y no representan el estado final.

## Cierre del 24/09/2026

| Archivo | Procedencia y alcance |
|---|---|
| format-cierre.txt | dart format, 75 archivos, 0 cambios, exit 0 |
| analyze-cierre.txt | flutter analyze sin incidencias, exit 0 |
| tests-cierre.txt | flutter test, 132 aprobadas, 1 omitida, 0 fallos, exit 0 |
| coverage-cierre.txt | flutter test --coverage, mismo resultado, exit 0 |
| lcov-cierre.info | Copia de LCOV actual; 1512/2227 líneas = 67,89 % |
| sentry-verificacion.md | Confirmación del propietario; no equivale a captura del panel |
| dispositivo-cierre.md | Lecturas ADB del TECNO KM4; no contiene tiempos de frames |

Los archivos *-final y los restantes logs anteriores son históricos. Se
sustituyeron rutas personales por <WORKSPACE>/<USER_HOME> en build-final,
coverage-final, coverage-run, e2e, overflow-before y tests-final, sin cambiar resultados.
La compilación exitosa en TEMP consta en la etapa anterior; no se adjunta APK
ni se afirma una compilación nueva del código actual. No se generaron capturas.

La medición Performance física está documentada en
`performance-profile-2026-09-25.json`: 26 frames, 59 FPS, 60 Hz activos,
UI máxima 3,8 ms, Raster máxima 12,4 ms y 0 jank. La exportación original se
conserva fuera del repositorio.

La evidencia visual sanitizada del evento Sentry está archivada en
`sentry-event-sanitized.png` y fue revisada para ocultar barra de direcciones, ID
del evento y Trace ID. Conserva StateError, `[REDACTED]` y la traza necesaria.

La comparación antes/después no aplica porque no se identificó un problema real
de fluidez; el requisito académico de corregirlo queda expresamente pendiente.
No versionar originales DevTools sin revisar, URLs de VM, DSN ni identificadores.
