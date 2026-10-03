# Logging

Auditoría de `mobile/lib`: ApiClient utilizaba debugPrint como salida por defecto de registros HTTP con ruta permitida, método, estado y duración. Su filtro ya excluye query, body, identificadores de ruta y texto de excepciones, y reemplaza la autorización por un marcador literal. Solo opera en DEV fuera de release. Se conserva para respetar la arquitectura de Semana 13.

Se añadió `services/app_logger.dart`: JSON con `level`, `module`, `action` y `errorType`. Soporta debug, info, warning y error. El contexto usa enums, sin parámetros de texto libre, objetos de excepción, payloads o identidades. La validación nueva del repositorio emite warning/orders/validate/invalidDraft. Los otros niveles están disponibles y probados, sin inventar eventos que la aplicación no produce.

La salida sigue usando debugPrint como sumidero local; el evento se estructura antes de llegar a él. No se sustituyen indiscriminadamente registros de componentes previos ni se modifica el backend. No hay envíos remotos.

`semana15_logging_test.dart` verifica campos exactos de los cuatro niveles y desactivación explícita. Junto con `semana13_prod_test.dart`, se ejecutó en `AMBIENTE=prod` con API_URL sintética HTTPS: 3 pruebas aprobadas, 0 omitidas. El transporte de esa prueba se intercepta, sin conexión al dominio.

No se registran access/refresh tokens, contraseñas, correos, cédulas, direcciones, coordenadas ni datos personales. Las pruebas previas de redacción HTTP permanecen y pasan. El logging HTTP anterior no se declara convertido a JSON: la incorporación estructurada se limita al nuevo control de validación.
