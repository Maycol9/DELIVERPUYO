# Monitoreo — estado de cierre

## Estado verificado

Sentry está integrado en la aplicación Flutter con filtros de privacidad locales.
El propietario confirmó la recepción remota de un evento real de prueba:
`StateError`, origen `SentryService.triggerTestCrash`, ambiente `dev`, versión
`1.0.0 (1)`, traza recibida y mensaje `[REDACTED]`. El usuario remoto es un
identificador aleatorio. No se generó otro evento durante este cierre.

La política detallada está en PRIVACIDAD_MONITOREO.md. No se imprime ni se
archiva el DSN. La confirmación textual está en
`evidence/semana15/sentry-verificacion.md`.

## Evidencia visual archivada

La captura sanitizada está archivada en
`evidence/semana15/sentry-event-sanitized.png`. La revisión visual confirma que
la barra de direcciones, el ID del evento y el Trace ID no aparecen; conserva
`StateError`, `[REDACTED]`, `SentryService.triggerTestCrash` y la referencia al
botón de prueba de Sentry.

La captura no se usa para afirmar versión o ambiente, que provienen de la
verificación remota comunicada y registrada en `sentry-verificacion.md`.
