# Uso de IA — Prototipo 13

Herramientas: ChatGPT y Codex, como apoyo para revisión, implementación, diagnóstico, pruebas y documentación. La IA no sustituye la revisión del propietario ni la evaluación docente.

## Verificaciones técnicas

- Cliente Dio, sesiones y refresh contrastados con código real del backend y tests.
- Secure storage: arquitectura existente y prueba Android histórica; ninguna herramienta leyó sus valores de sesión en este cierre.
- Reintentos, anti-bucle y concurrencia: suite automatizada; cinco solicitudes y una renovación.
- HTTPS y logging PROD: tests bajo AMBIENTE=prod, incluidos bloqueo del diagnóstico y cero solicitudes fuera de DEV.
- Idempotencia: backend no tiene claves idempotentes; POST no se repite ante resultado de red ambiguo. La evidencia no afirma entrega exactamente una vez.
- Middleware: la prueba real descubrió un 422 convertido indebidamente en 401. Se corrigió el alcance del catch y se añadieron siete pruebas sin claves ni sesiones reales.
- Capturas: adb screencap real y revisión visual. No se generaron imágenes ni se representaron tests simulados como llamadas reales.

## Intervención humana

El usuario ingresó manualmente a la cuenta de prueba con dirección existente. No se pidió ni utilizó una contraseña por herramientas. El usuario autorizó un único pedido y una herramienta de diagnóstico DEV aislada. La revisión final del diff por el propietario y la nota docente siguen siendo humanas.

## Incidencias y límites

Una búsqueda previa del seed mostró accidentalmente contraseñas de prueba en la salida de herramienta. No se copian aquí ni se usaron para autenticarse. No se afirma que toda la sesión de trabajo estuvo libre de exposición. Los logs nuevos y las doce capturas se revisan por separado.

El primer ensayo inválido encontró un fallo de middleware, produjo dos 401 con una renovación y cerró sesión por anti-bucle; no se declara como 422 exitoso. Requiere login manual posterior. La documentación final distingue ese ensayo del flujo correcto posterior.

Las pruebas de transporte simulado, las pruebas reales Android y las evidencias históricas se identifican como tales. No se promete 10/10 sin verificaciones completas.
