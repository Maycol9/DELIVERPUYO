# Base para informe técnico Semana 10

## 1. Descripción de DeliverPuyo

DeliverPuyo es un proyecto académico de delivery con backend Next.js, Prisma, PostgreSQL, Redis y aplicación móvil Flutter.

## 2. Inventario de pantallas y endpoints

Usar la tabla de `docs/semana10/INVENTARIO_PANTALLAS.md`.

## 3. Sistema de tokens

Primitivos: valores puros como `green800`, `white`, `gray900`.

Semánticos: funciones visuales como `colorPrimary`, `colorBackground`, `colorError`.

Componente: widgets consumen `ThemeData` y `AppTokens`.

## 4. Contraste WCAG 2.2

Usar mediciones de `docs/semana10/CONTRASTE_WCAG.md`.

## 5. Catálogo de componentes

Componentes: `AppPrimaryButton`, `AppTextField`, `StateView`, `ProductCard`.

## 6. Interfaz pública de cada componente

Usar tablas de `docs/semana10/CATALOGO_COMPONENTES.md`.

## 7. Código de los componentes

Para el informe posterior, incluir fragmentos representativos:

- Constructor público de cada componente.
- Uso de `Theme.of(context)` y `context.tokens`.
- `StateViewType`.
- Ejemplo de `ProductCard` recibiendo datos por parámetros.

No copiar archivos completos gigantes.

## 8. Justificación de reutilización

Los componentes tienen pocos parámetros obligatorios, reciben datos, exponen callbacks, no conocen endpoints ni rutas y usan composición.

## 9. Estados cargando, vacío y error

Implementados con `StateView` y usados en `ProductsScreen`.

## 10. Pantalla real ensamblada

`mobile/lib/screens/products_screen.dart` consume `GET /api/products`.

## 10.1 API real

`GET /api/products` respondió `success:true` con datos reales. Para Flutter Web se habilitó CORS de desarrollo limitado a `http://localhost:8081` en productos y categorías.

## 11. Diseño responsivo/adaptativo

La pantalla usa `SliverLayoutBuilder` para decidir una, dos o tres columnas según ancho disponible.

## 12. Accesibilidad

Incluye contraste AA, controles Material con mínimo 48 puntos, mensajes no dependientes solo del color y `Semantics`.

## 13. Uso de inteligencia artificial

Ver `docs/semana10/USO_IA.md`.

## 14. Evidencias pendientes

Ver `evidence/semana10/CHECKLIST_EVIDENCIAS.md`.

## 15. Enlace al repositorio

Repositorio remoto detectado: `https://github.com/Maycol9/DELIVERPUYO.git`.
