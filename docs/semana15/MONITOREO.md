# Monitoreo — pausa explícita

ACCIÓN MANUAL REQUERIDA — MONITOREO

La auditoría no encontró Crashlytics, Sentry u otro SDK de reporte de fallos en lib/pubspec. Se selecciona Sentry para la siguiente etapa: dispone de SDK oficial Flutter con captura de errores Dart y nativos, sin exigir incorporar Firebase a esta arquitectura. Su plan Developer figura como gratuito para un usuario en la [página oficial de precios](https://sentry.io/pricing/), consultada el 2026-09-22. No se contrató ningún plan.

El [SDK oficial sentry_flutter](https://pub.dev/packages/sentry_flutter) requiere una cuenta y DSN de proyecto. El usuario no proporcionó esa configuración. Conforme a la instrucción explícita del encargo, se detiene aquí la implementación del servicio: no se agregó un DSN ficticio, no se modificó .env/pubspec, no se envió telemetría y no se declara monitoreo configurado.

## Acción del propietario

Crear o seleccionar un proyecto Flutter de Sentry en el plan gratuito y facilitar la configuración real del proyecto para continuar. No se necesita compartir la contraseña de la cuenta ni un token administrativo. El DSN debe suministrarse mediante la configuración de compilación acordada, sin registrarlo en logs.

## Trabajo que queda para la continuación

Integrar el SDK compatible y su inicialización; implementar y probar la política descrita en PRIVACIDAD_MONITOREO.md; comprobar versión de app y stack trace; después enviar un único fallo sintético controlado desde un entorno de prueba y verificarlo en el panel. El mecanismo de prueba no debe quedar activo en producción.

No existe evidencia de fallo remoto recibido. Versión actual del proyecto: `1.0.0+1`, leída de pubspec; eso no demuestra que el servicio la haya recibido. No se construyó una falsa confirmación de crash reporting.
