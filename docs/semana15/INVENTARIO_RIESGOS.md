# Inventario de riesgos

Escala cualitativa: probabilidad y consecuencia de 1 (baja) a 3 (alta); prioridad = producto. Son estimaciones para priorizar, no tasas medidas de fallos.

| Riesgo | Probabilidad | Impacto | Prioridad | Prueba asociada | Motivo |
|---|---:|---:|---:|---|---|
| Usuario no puede iniciar sesión | 2 | 3 | 6 | 1: autenticación | Bloquea pedidos y rutas protegidas |
| Credenciales inválidas aceptadas o mal manejadas | 2 | 3 | 6 | 1: autenticación | Debe rechazar sesión y mostrar error manejado |
| Pedido inválido enviado al backend | 3 | 3 | 9 | 2: validación | La barrera observada está en formulario; falta verificar repositorio |
| Pedido perdido sin conexión | 3 | 3 | 9 | 3: outbox | Persistencia, timeout y reintento deben conservar el borrador |
| Catálogo muestra pantalla incorrecta | 2 | 2 | 4 | 4: catálogo | Loading, data, empty y error orientan la acción del usuario |
| Ruptura entre login, productos y pedido | 2 | 3 | 6 | 5: único E2E crítico | Pruebas aisladas no verifican navegación y envío conjunto |
| Pedido duplicado tras timeout de POST | 2 | 3 | 6 | 3: outbox, HTTP | Resultado ambiguo exige conservar marcador y evitar replay automático |

Las cinco pruebas seleccionadas se mantienen. HTTP, formulario, logging y cobertura las complementan.
