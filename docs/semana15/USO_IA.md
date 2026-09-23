# Uso de IA

Herramienta: Codex, asistente de OpenAI/ChatGPT, trabajando sobre el repositorio local. No se utilizaron agentes delegados.

Consultas y tareas: auditoría de pruebas reales, priorización de riesgos, diseño de dobles HTTP y almacenamiento, pruebas de autenticación/validación/outbox/catálogo, E2E, lectura de LCOV, logging, monitoreo y CI.

Modificaciones reales verificadas en este cierre: ampliación de `semana15_auth_test.dart` con credenciales válidas, 401 y fallo de transporte, además de actualización de resultados y límites documentales. Se conservaron los cambios previos: validación mínima en `OrderRepository`, corrección de overflow en `CreateOrderScreen`, `AppLogger`, pruebas prioritarias, E2E crítico, workflow Flutter y documentos Semana 15. Se reutilizaron `Adapter`, `MemorySession` y `jsonBody`, sin duplicar la prueba 422.

Las pruebas generadas fueron revisadas para confirmar que comprueban comportamiento real y no solo ejecutan código: ausencia de envío inválido, persistencia íntegra y reintento único, bloqueo de replay ambiguo, estados visibles/reintento y navegación con POST real sobre transporte falso. El E2E usa la app, router, API y repositorios de producción; no invoca create() directamente para simular un resultado.

Solo se utilizan resultados ejecutados y observados. Se conservaron pruebas previas y no se fabricaron cobertura, fallos externos ni métricas físicas. Los datos de tests son sintéticos. La revisión estática y automática no equivale a una revisión humana independiente.

Verificación: flutter analyze, flutter test, flutter test --coverage y pruebas específicas PROD. El resultado final de E2E y build se registra en DOCUMENTO_PROTOTIPO15.md y las evidencias. El CI remoto no se ha ejecutado y ninguna medición física se ha realizado.
