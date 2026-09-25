# Uso de inteligencia artificial Semana 10

## Herramienta

ChatGPT / Codex.

## Uso realizado

- Análisis de requisitos.
- Inspección de endpoints reales.
- Propuesta inicial de estructura.
- Generación y refactorización de componentes.
- Apoyo en sistema de tokens.
- Generación inicial de documentación.
- Apoyo en pruebas automatizadas.
- Diagnóstico y ajuste mínimo de CORS de desarrollo para Flutter Web.

## Resultados utilizados

Se utilizó código para tema Flutter, `ThemeExtension`, componentes reutilizables, pantalla de catálogo, traducción de errores HTTP, tests de widgets y documentación técnica.

## Modificaciones realizadas

La solución se adaptó a DeliverPuyo usando endpoints reales del backend, especialmente `GET /api/products` y `GET /api/categories`. Se conservó la prueba de conectividad de Semana 9 dentro de la nueva pantalla y se limitó CORS de desarrollo al origen `http://localhost:8081`.

## Verificaciones

| Verificación | Estado |
| ------------ | ------ |
| `flutter analyze` | Ejecutado: sin issues. |
| `flutter test` | Ejecutado: 7 pruebas pasaron. |
| Ejecución en Android | Ejecutado en `emulator-5554` con `API_URL=http://10.0.2.2:3000`; captura real guardada en `evidence/semana10/06_ancho_telefono.png`. |
| API real | Verificada con `GET http://localhost:3000/api/products?page=1&limit=1`; respuesta `success:true` con producto real. |
| Contraste WCAG | Calculado y documentado en `CONTRASTE_WCAG.md`. |
| TalkBack | Manual pendiente. |
| Fuente ampliada | Manual pendiente. |
| Dos anchos | Manual pendiente. |
