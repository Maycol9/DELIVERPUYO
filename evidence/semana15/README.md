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

Pendientes: exportación Performance sanitizada, frecuencia durante el recorrido,
análisis UI/Raster y evidencia sanitizada del evento Sentry ya recibido.
Comparación antes/después solo si se identifica y corrige un problema real.
No versionar originales DevTools sin revisar, URLs de VM, DSN ni identificadores.
