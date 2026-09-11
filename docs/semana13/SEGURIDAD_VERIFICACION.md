# Verificación local y límite de seguridad

La revisión automática rechazó una propuesta de auxiliar que leería la contraseña de demostración de prisma/seed.ts y el secreto JWT local para entregar credenciales al proceso de pruebas y firmar un access token expirado. El rechazo ocurrió antes de crear o ejecutar el auxiliar. No se ejecutó mediante otra vía y no se modificó .env ni el TTL.

Motivo comunicado por la revisión: la autorización general de pruebas no cubre esa transferencia sensible de credenciales o derivados. Las pruebas autenticadas requieren login manual en el emulador o aprobación explícita de un procedimiento concreto. No se deben pegar contraseñas ni tokens en el chat.

Alternativa ejecutada: integration_test consulta únicamente GET /api/products real, comprueba caché y una entrada no secreta temporal del plugin seguro (eliminada al terminar), y captura la superficie real de Flutter. No lee las claves de la sesión.

La prueba offline posterior solo cambia conectividad de emulator-5554. Está autorizada expresamente por la fase 22 del encargo y usa finally para restaurar modo avión desactivado, Wi-Fi y datos activos. No cambia la conectividad del equipo y no transfiere credenciales.

La captura 12 es un panel de resultados de la prueba Android, no una pantalla añadida al producto. Se muestra después de comprobar realmente lectura/escritura del plugin y rechazo de HTTP para prod. Las capturas de login muestran el formulario, no prueban autenticación exitosa.
