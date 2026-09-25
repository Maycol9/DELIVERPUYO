# Uso de IA — Prototipo 13

Herramientas empleadas: ChatGPT y Codex, como apoyo para revisión técnica, diagnóstico, implementación, pruebas automatizadas y documentación. La IA no reemplaza la responsabilidad final del propietario del proyecto ni la evaluación docente.

## Alcance del uso

La asistencia de IA se utilizó para:

- revisar el contrato real del backend y contrastarlo con la lógica de autenticación, sesiones y refresh;
- diagnosticar errores de middleware, manejos HTTP y flujo de pedidos;
- apoyar la implementación de correcciones mínimas y verificables;
- generar y ajustar pruebas automatizadas de regresión;
- resumir evidencias, diferencias de comportamiento y límites del prototipo;
- preparar la documentación técnica final con trazabilidad hacia pruebas reales.

No se utilizó la IA para sustituir la validación humana ni para afirmar resultados que no se ejecutaron en el proyecto.

## Verificaciones técnicas realizadas

- Cliente Dio, sesiones y refresh: contrastados con el código real del backend y con las pruebas del flujo de autenticación.
- Secure storage: se revisó la arquitectura existente y la prueba Android histórica; ninguna herramienta leyó valores de sesión durante este cierre de trabajo.
- Reintentos, anti-bucle y concurrencia: verificados mediante suite automatizada con cinco solicitudes y una renovación del token.
- HTTPS y logging de producción: pruebas ejecutadas bajo `AMBIENTE=prod`, con bloqueo del diagnóstico y ausencia de solicitudes fuera del entorno de desarrollo.
- Idempotencia: el backend no implementa claves idempotentes; cuando el resultado de red es ambiguo, el sistema no reenvía automáticamente el pedido. La evidencia no afirma entrega exactamente una vez.
- Middleware de autenticación: la prueba real mostró que un 422 era convertido indebidamente en 401. Se corrigió el alcance del `catch` y se añadieron pruebas sin claves ni sesiones reales.
- Capturas y evidencia visual: se emplearon capturas reales con `adb screencap` y revisión visual manual. No se generaron imágenes falsas ni se representaron pruebas simuladas como llamadas reales.
- Diagnóstico DEV aislado: se ejecutó una comprobación limitada y controlada para confirmar que el error real de validación se reportaba correctamente sin acarrear creación de pedidos.

## Intervención humana

La intervención humana fue determinante en los puntos críticos:

- El usuario ingresó manualmente a la cuenta de prueba con dirección existente.
- No se pidió ni se utilizó ninguna contraseña por parte de las herramientas.
- El usuario autorizó un único pedido real y una comprobación de diagnóstico DEV aislada.
- La revisión final del `diff`, la validación del comportamiento y la nota docente quedaron en manos humanas.

La IA apoyó la revisión y el diagnóstico, pero la decisión final y la responsabilidad del cierre técnico siguen siendo humanas.

## Incidencias y límites

Durante la revisión se detectó una incidencia puntual:

- una búsqueda previa del seed mostró contraseñas de prueba en la salida de una herramienta; esos valores no se copiaron ni se utilizaron para autenticarse.

Además, se cumplieron estas limitaciones de forma explícita:

- No se afirma que toda la sesión de trabajo estuvo libre de exposición; los logs nuevos y las capturas se revisan por separado.
- El primer ensayo inválido encontró un fallo de middleware, provocó dos 401 con renovación y cerró sesión por anti-bucle; ese caso no se declara como un 422 exitoso y requiere login manual posterior.
- La documentación final distingue claramente entre el ensayo fallido inicial y el flujo correcto posterior.
- Las pruebas de transporte simulado, las pruebas reales Android y las evidencias históricas se identifican como tales. No se promete un resultado de 10/10 sin verificaciones completas.

## Conclusión

El uso de IA fue válido como apoyo técnico para detectar problemas, proponer correcciones mínimas, preparar evidencias y documentar el estado real del prototipo, siempre bajo revisión humana. La verificación final del proyecto se apoyó en pruebas reales, trazabilidad del código y contraste con la implementación del backend, sin reemplazar la supervisión del propietario ni la evaluación académica.
