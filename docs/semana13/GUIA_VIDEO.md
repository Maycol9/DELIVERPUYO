# Guía de video — Semana 13

Mostrar únicamente datos de demostración. No grabar la escritura de credenciales ni valores de autenticación. Usar el índice de evidencias y los logs limitados a ruta/estado. No presentar un ensayo fallido como prueba exitosa.

1. Presentar DeliverPuyo y su integración Flutter/Next.js.
2. Mostrar el formulario de login y cortar la grabación durante el ingreso manual; volver con sesión iniciada.
3. Abrir el catálogo consultado desde el backend real.
4. Señalar los 15 productos y la respuesta GET 200.
5. Explicar la creación con una dirección existente, Producto 1 y cantidad 1. Usar la captura 03 ya tomada: no crear otro pedido para grabar.
6. Mostrar el pedido d6528596-e558-40b9-9f5f-7ac184f82d64 y la captura 04; total $4,00, POST 201.
7. Explicar que Dio concentra las llamadas HTTP.
8. Explicar que la sesión se guarda cifrada; no abrir almacenamiento seguro.
9. Mostrar la captura 05 de una pantalla protegida con sesión válida, indicando su fecha real.
10. Mostrar el 401 del flujo de renovación elegido en el log redactado.
11. Mostrar la única llamada POST /api/auth/refresh 200 de ese mismo flujo.
12. Mostrar el reintento protegido con 200.
13. Mostrar pantalla protegida posterior (06) y explicar que el usuario siguió autenticado. No mezclar flujos: el ensayo 422 anterior al arreglo del middleware cerró sesión y está documentado como incidencia.
14. Explicar el diagnóstico DEV de cantidad 0, que utiliza el esquema real. No volver a pulsarlo si ya se dispone de 07/08.
15. Mostrar 07/08 y el mensaje real junto a Cantidad, conservando los valores válidos del formulario. Si falta evidencia, declararlo pendiente.
16. Explicar la desconexión documentada; usar la captura real 10 sin repetir cortes innecesarios.
17. Mostrar productos conservados por la caché y el aviso offline.
18. Explicar la restauración de red/backend.
19. Mostrar GET 200 y la captura 11; aclarar que demuestra catálogo, no envío de outbox real.
20. Explicar HTTPS PROD, logging PROD desactivado, ausencia de secretos en capturas y bloqueo del diagnóstico fuera de DEV. Mostrar 12 y los tests actuales.
21. Cerrar con los resultados reales de pruebas y pendientes del informe. La rúbrica es potencial, no nota oficial.

La prueba Android automatizada existente reinstala la app y muestra una pantalla de prueba; no ejecutarla sobre esta sesión como parte del video. No repetir creación, login ni refresh solo para aumentar el número de pruebas.
