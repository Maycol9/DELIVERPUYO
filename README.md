# DeliverPuyo - Avance 8: optimización del backend

Backend académico de **DeliverPuyo**, con Next.js, TypeScript, Prisma/PostgreSQL, Redis, BullMQ, JWT y Zod.

## Mejoras implementadas

1. **Caché cache-aside** en `GET /api/products`, Redis, TTL de 120 segundos, estado `MISS/HIT/BYPASS` e invalidación explícita al crear o actualizar productos.
2. **Corrección de N+1** en el listado de pedidos mediante `relationLoadStrategy: 'join'`, eager loading y selección de campos.
3. **Lazy/eager loading justificado**: listados cargan relaciones necesarias; el detalle solo carga dirección si `?include=address`.
4. **Cola de trabajo** con BullMQ: la creación de un pedido encola un comprobante PDF y responde inmediatamente.
5. **Autenticación eficiente**: el access token JWT se valida localmente; no se consulta la base en cada solicitud protegida. El refresh token sí se valida contra la base para permitir revocación.
6. **Respuesta optimizada**: paginación máxima 50, selección de campos mediante `fields`, compresión HTTP y JSON reducido para la aplicación móvil.
7. **Evidencia automática**: endpoint de benchmark y script que guarda resultados reales en `evidence/benchmark-results.json`.

## Requisitos

- Node.js 22+
- Docker Desktop o PostgreSQL 17 + Redis 7

## Ejecución paso a paso

```powershell
Copy-Item .env.example .env
docker compose up -d
npm install
npm run generate
npm run migrate-dev -- --name init
npm run seed
```

Terminal 1:
```powershell
npm run dev
```

Terminal 2:
```powershell
npm run worker:receipt
```

Terminal 3, para generar evidencia real:
```powershell
npm run benchmark
```

## Usuarios de prueba

- Administrador: `admin@deliverpuyo.local` / `Admin1234`
- Cliente: `cliente@deliverpuyo.local` / `Cliente1234`

## Endpoints principales

| Método | Endpoint | Protección | Optimización |
|---|---|---|---|
| POST | `/api/auth/register` | Público | Hash bcrypt + JWT |
| POST | `/api/auth/login` | Público | Emite access/refresh token |
| POST | `/api/auth/refresh` | Público con refresh | Rotación y revocación |
| GET | `/api/categories` | Público | Catálogo reducido |
| GET/POST | `/api/addresses` | JWT | Solo direcciones del usuario |
| GET | `/api/products` | Público | Redis, paginación, fields, gzip |
| POST | `/api/products` | ADMIN | Invalida caché |
| PATCH | `/api/products/{id}` | ADMIN | Invalida caché |
| GET | `/api/orders` | JWT | Eager loading / JOIN |
| POST | `/api/orders` | JWT | Transacción + cola PDF |
| GET | `/api/orders/{id}?include=address` | JWT | Carga opcional controlada |
| GET | `/api/debug/orders-benchmark` | ADMIN | Evidencia N+1 vs JOIN |

## Evidencias sugeridas para el video

1. Postman: primera consulta de productos `X-Cache: MISS` y segunda `X-Cache: HIT`.
2. Actualizar un producto y comprobar que la siguiente consulta vuelve a `MISS`.
3. Ejecutar benchmark N+1 y optimizado; comparar `databaseCalls` y `durationMs`.
4. Crear un pedido: observar respuesta inmediata y luego PDF en `storage/receipts`.
5. Mostrar que middleware JWT no ejecuta consulta de usuario por cada solicitud.
6. Abrir `evidence/benchmark-results.json` generado por el script.

## Resultados reales conservados

Las métricas reales del Avance 8 están en `evidence/benchmark-results.json`, `evidence/benchmark-summary.txt` y `evidence/queue-status.txt`.

| Optimización | Antes / MISS | Después / HIT | Mejora |
|---|---:|---:|---:|
| Caché HTTP estable | 103.91 ms | 11.31 ms | 89.12 % |
| Consultas N+1 | 81 consultas | 1 consulta | 98.77 % |
| Tiempo interno N+1 | 93.69 ms | 6.80 ms | 92.74 % |
| Tiempo HTTP N+1 | 153.80 ms | 17.12 ms | 88.87 % |

Estado real de BullMQ registrado: `wait: 0`, `active: 0`, `completed: 1`, `failed: 0`, `delayed: 0`, `paused: 0`.

## Documentación técnica

- `docs/avance8/AUDITORIA_CODEX_AVANCE8.md`
- `docs/avance8/GUIA_EJECUCION.md`
- `docs/avance8/MATRIZ_CUMPLIMIENTO.md`
- `docs/avance8/USO_RESPONSABLE_IA.md`

## Nota de honestidad académica

Los tiempos dependen del computador y deben obtenerse ejecutando `npm run benchmark`. El proyecto no incluye cifras inventadas; genera la evidencia técnica real en el entorno del estudiante.

# Avance 9 — Aplicación móvil Flutter

## Framework seleccionado

Flutter y Dart.

## Justificación técnica

Flutter permite desarrollar una aplicación móvil multiplataforma con una sola base de código. Para este avance es adecuado porque incluye Hot Reload, facilita la creación rápida de interfaces y puede integrarse mediante HTTP con la API REST existente del backend DeliverPuyo.

## Arquitectura

```text
Aplicación Flutter
        ↓
API REST
        ↓
Backend DeliverPuyo
        ↓
Base de datos
```

## Entorno utilizado

- Windows: Microsoft Windows 10.0.26300.9032, reportado por Flutter como Windows 11 o superior 26H2.
- Flutter: 3.44.4, canal stable, instalado en `C:\src\flutter`.
- Dart: 3.12.2 stable.
- DevTools: 2.57.0.
- Java/JDK en PATH: OpenJDK 11.0.7 AdoptOpenJDK.
- Java/JDK configurado en Flutter: Temurin OpenJDK 17.0.20+8.
- Android SDK: 36.0.0 en `C:\Android\Sdk`.
- Android SDK Platform: android-36.
- Android Build Tools: 36.0.0.
- Android Platform Tools / ADB: 37.0.1.
- Android Emulator: 37.1.11.0.
- Android Studio: 2025.3.4.7, versión de producto `AI-253.32098.37.2534.15336583`.
- AVD Android: `DeliverPuyo_API_36`, Android 16 / API 36, `google_apis/x86_64`.
- Git: 2.45.1.windows.1.

## Verificación

Comandos ejecutados y guardados como evidencia en `evidence/semana9/`:

```powershell
flutter --version
flutter doctor -v
flutter devices
java -version
git --version
adb version
```

El comando `flutter doctor -v` confirmó Flutter, Dart, Android SDK, JDK 17 configurado en Flutter y licencias Android aceptadas. `flutter devices` detectó el emulador Android `emulator-5554`, además de Windows, Chrome y Edge. El único issue restante de `flutter doctor -v` corresponde a Visual Studio para desarrollo Windows desktop, que no bloquea la ejecución Android de esta tarea.

## Aplicación móvil

La aplicación móvil se encuentra en:

```text
/mobile
```

Fue creada como proyecto independiente para no reemplazar ni dañar el backend existente:

```powershell
flutter create --org com.deliverpuyo --project-name deliverpuyo_mobile mobile
```

La pantalla inicial muestra `DeliverPuyo Móvil`, una descripción técnica del cliente móvil y el botón `PROBAR CONEXIÓN CON API`.

## Dependencias Flutter

Dependencias principales:

- `flutter`
- `cupertino_icons`
- `http`

La dependencia `http` fue agregada con:

```powershell
flutter pub add http
```

Los archivos `mobile/pubspec.yaml` y `mobile/pubspec.lock` deben versionarse.

## URL de la API

La URL base no está repetida en la aplicación. Se centralizó en:

```text
mobile/lib/config/api_config.dart
```

Configuración:

```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
```

Para Android Emulator:

```text
http://10.0.2.2:3000
```

Para un dispositivo físico:

```text
http://<IP_LOCAL_PC>:3000
```

`localhost` no sirve desde un Android Emulator para consumir el backend en Windows porque `localhost` apunta al propio emulador. Android Emulator usa `10.0.2.2` para acceder a la máquina anfitriona.

## Ejecución

Desde la carpeta `mobile`:

```powershell
flutter pub get
flutter run -d emulator-5554 --disable-dds --dart-define=API_URL=http://10.0.2.2:3000
```

El puerto documentado es `3000` porque el backend se ejecuta con el script real:

```powershell
npm run dev
```

Ese script ejecuta `next dev`, cuyo puerto por defecto es `3000` si no se define otro.

## Endpoint de verificación

Endpoint real identificado en el backend:

```text
GET /api/categories
```

Archivo backend:

```text
pages/api/categories/index.ts
```

Este endpoint es público para `GET` y devuelve categorías activas con una estructura similar a:

```json
{
  "success": true,
  "data": []
}
```

## Seguridad

Android moderno bloquea tráfico HTTP en texto plano. Para desarrollo local se agregó:

```text
mobile/android/app/src/main/res/xml/network_security_config.xml
```

La configuración permite HTTP únicamente hacia:

```text
10.0.2.2
```

También se conectó desde:

```text
mobile/android/app/src/main/AndroidManifest.xml
```

Esta excepción es exclusiva para desarrollo local. En producción debe eliminarse y el backend debe utilizar HTTPS.

## Hot Reload

Para comprobar Hot Reload:

1. Ejecutar la app con `flutter run -d emulator-5554 --disable-dds --dart-define=API_URL=http://10.0.2.2:3000`.
2. Cambiar temporalmente un texto visible en `mobile/lib/main.dart`.
3. Presionar `r` en la terminal de Flutter o guardar desde el IDE.
4. Confirmar que el texto cambia sin reconstrucción completa.
5. Dejar nuevamente el texto definitivo `DeliverPuyo Móvil`.

En esta verificación se ejecutó la aplicación en Android con `flutter run`. Para este equipo se usa `--disable-dds` porque una ejecución anterior mostró un error de conexión al Dart Development Service en Windows, aunque la app sí compilaba e instalaba correctamente. Con ese ajuste la app queda abierta en el emulador y se puede usar la consola interactiva de Flutter para Hot Reload con la tecla `r`.

## Limitaciones

- `java -version` en el PATH del sistema todavía reporta OpenJDK 11.0.7, pero Flutter quedó configurado explícitamente con Temurin JDK 17.0.20.
- `flutter doctor -v` mantiene un issue de Visual Studio para compilar aplicaciones Windows desktop. No afecta Android.
- Existe un AVD anterior `Medium_Phone_API_36.0` con imagen faltante `android-36\google_apis_playstore\x86_64`; no se eliminó porque no es necesario para DeliverPuyo. El AVD funcional usado es `DeliverPuyo_API_36`.
- Para evitar el error local de Dart Development Service en Windows, la ejecución Android se documenta con `--disable-dds`. Hot Reload se demuestra desde la consola Flutter con la tecla `r`.
- iOS no se compila localmente en Windows porque requiere macOS y Xcode.

## Dificultades y soluciones

- Flutter y Dart no respondieron dentro del sandbox inicial. Se ejecutaron fuera del sandbox para usar el SDK real instalado en `C:\src\flutter`.
- `flutter analyze` falló inicialmente porque el test generado seguía usando `MyApp` del contador. Se actualizó `mobile/test/widget_test.dart` para validar la pantalla real de DeliverPuyo.
- Android Studio se instaló con `winget`. El Android SDK se instaló mediante command-line tools oficiales y se configuró en `C:\Android\Sdk` para evitar espacios en la ruta.
- Se instaló Temurin JDK 17 con `winget` y se configuró Flutter con `flutter config --jdk-dir`.
- Docker Desktop se inició y luego `docker compose up -d` dejó PostgreSQL y Redis en estado `healthy`.
- El backend se inició con `npm run dev` y `GET /api/categories` respondió HTTP 200 con categorías reales.
- La aplicación Flutter se ejecutó en el emulador Android y el botón `PROBAR CONEXIÓN CON API` mostró `Conexión exitosa`, `Código HTTP: 200` y datos reales del backend.

## Uso de inteligencia artificial

Se utilizó ChatGPT/Codex como apoyo para:

- análisis de requisitos;
- revisión de configuración;
- generación inicial de código;
- diagnóstico técnico.

Las instrucciones, archivos modificados y verificaciones automatizables fueron revisados sobre el entorno real. La conexión Flutter → API DeliverPuyo fue verificada con backend, Docker, base de datos y emulador Android ejecutándose.

# Avance 10 — Sistema de diseño y componentes reutilizables

## Objetivo

Preparar la aplicación Flutter de DeliverPuyo con sistema de diseño, componentes reutilizables, pantalla real ensamblada, estados de interfaz, accesibilidad WCAG 2.2 y documentación técnica.

## Inventario de pantallas

| Pantalla | Endpoint |
| -------- | -------- |
| Inicio de sesión | `POST /api/auth/login` |
| Registro | `POST /api/auth/register` |
| Renovar sesión | `POST /api/auth/refresh` |
| Categorías | `GET /api/categories` |
| Catálogo de productos | `GET /api/products` |
| Crear producto | `POST /api/products` |
| Editar producto | `PATCH /api/products/{id}` |
| Direcciones | `GET /api/addresses` |
| Crear dirección | `POST /api/addresses` |
| Pedidos | `GET /api/orders` |
| Crear pedido | `POST /api/orders` |
| Detalle de pedido | `GET /api/orders/{id}?include=address` |

El inventario completo está en `docs/semana10/INVENTARIO_PANTALLAS.md`.

## Sistema de tokens

Se agregaron tokens en `mobile/lib/theme/`:

- Primitivo: valor visual puro, por ejemplo `green800`, `white`, `gray900`.
- Semántico: función de interfaz, por ejemplo `colorPrimary`, `colorTextPrimary`, `colorError`.
- Componente: consumo desde `ThemeData`, `ColorScheme` y `AppTokens`.

Colores principales:

| Token | Valor |
| ----- | ----- |
| `colorPrimary` | `#006C57` |
| `colorOnPrimary` | `#FFFFFF` |
| `colorBackground` | `#F7FAF9` |
| `colorSurface` | `#FFFFFF` |
| `colorTextPrimary` | `#17211F` |
| `colorTextSecondary` | `#52615D` |
| `colorError` | `#B3261E` |

## Contraste

| Par | Relación | Resultado |
| --- | -------: | --------- |
| `colorPrimary / colorOnPrimary` | 6.40:1 | Cumple AA |
| `colorTextPrimary / colorBackground` | 15.70:1 | Cumple AA |
| `colorTextSecondary / colorBackground` | 6.20:1 | Cumple AA |
| `colorError / colorSurface` | 6.54:1 | Cumple AA |
| `colorOutline / colorSurface` | 3.29:1 | Cumple para componentes |

Detalle en `docs/semana10/CONTRASTE_WCAG.md`.

## Tipografía

La escala se centralizó en `ThemeData.textTheme` con `displaySmall`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium` y `labelLarge`. No se deshabilita el escalado de fuente del sistema.

## Espaciado

Se usa base de 8 puntos lógicos mediante `AppTokens`: `xs=4`, `sm=8`, `md=16`, `lg=24`, `xl=32`.

## Radios

Los radios están centralizados en `AppTokens`: campo `8`, botón `8`, tarjeta `8`.

## Componentes reutilizables

| Componente | Propósito | Entradas/configuración/callbacks | Estados | Justificación |
| ---------- | --------- | -------------------------------- | ------- | ------------- |
| `AppPrimaryButton` | Acción principal | `text`, `loading`, `enabled`, `onPressed`, `icon` | normal, disabled, loading | No conoce negocio ni API; comunica intención con callback. |
| `AppTextField` | Entrada de formularios | `label`, `controller`, `initialValue`, `onChanged`, `errorText`, `obscureText`, `keyboardType`, `enabled`, `prefix`, `suffix` | normal, focused, disabled, error | Reutilizable en login, registro, direcciones y búsqueda. |
| `StateView` | Cargando, vacío y error | `type`, `message`, `title`, `onRetry`, `actionText`, `child` | loading, empty, error | Evita repetir estados de pantalla y traduce errores a mensajes claros. |
| `ProductCard` | Representación de producto | `name`, `price`, `stock`, `description`, `category`, `imageUrl`, `onTap`, `trailing`, `compact` | normal, pressed, sin imagen, sin stock | Recibe datos; no consulta API ni decide navegación. |
| `CategoryFilterChip` | Filtro visual de categoría | `label`, `selected`, `onSelected` | normal, selected, focused | Filtra localmente datos reales y no conoce endpoints. |

La interfaz pública completa está en `docs/semana10/CATALOGO_COMPONENTES.md`.

## Pantalla implementada

Se implementó `mobile/lib/screens/products_screen.dart`, que consume el endpoint real público:

```text
GET /api/products?page=1&limit=20&fields=id,name,price,stock,imageUrl,category
```

La pantalla conserva la verificación de Semana 9 mediante el botón `PROBAR CONEXIÓN CON API`, que consulta `GET /api/categories`.

## Ejecución Flutter Web

Para web, el navegador corre en Windows y debe usar `localhost` para alcanzar el backend:

```powershell
cd mobile
flutter run -d edge --web-port=8081 --dart-define=API_URL=http://localhost:3000
```

Para evidencias visuales sin modificar la base de datos:

```powershell
flutter run -d edge --web-port=8081 --dart-define=API_URL=http://localhost:3000 --dart-define=UI_DEMO_STATE=loading
flutter run -d edge --web-port=8081 --dart-define=API_URL=http://localhost:3000 --dart-define=UI_DEMO_STATE=empty
flutter run -d edge --web-port=8081 --dart-define=API_URL=http://localhost:3000 --dart-define=UI_DEMO_STATE=error
flutter run -d edge --web-port=8081 --dart-define=API_URL=http://localhost:3000 --dart-define=UI_DEMO_STATE=normal
```

Para Flutter Web se habilitó CORS de desarrollo únicamente para `http://localhost:8081` en los endpoints usados por la app móvil (`/api/products` y `/api/categories`). No se usa wildcard `*`.

## Ejecución Android Emulator

Para Android Emulator, `localhost` apunta al emulador, no a Windows. Por eso se usa `10.0.2.2`:

```powershell
cd mobile
flutter devices
flutter run -d <ID_REAL> --dart-define=API_URL=http://10.0.2.2:3000
```

## Estados

La pantalla de productos contempla:

- cargando: `Cargando productos...`;
- con datos: tarjetas `ProductCard`;
- vacío: `No hay productos disponibles en este momento.`;
- error: mensaje comprensible y acción `REINTENTAR`.

El rediseño visual del catálogo organiza título, subtítulo, contador real de productos, buscador, filtros de categoría derivados de la API, estado de conexión secundario y tarjetas responsivas.

## Responsividad

La pantalla usa `SliverLayoutBuilder` para decidir columnas según el ancho disponible: una columna en teléfono, dos en ancho medio y tres en ancho grande.

## Accesibilidad

Se aplican criterios WCAG 2.2:

- contraste AA calculado;
- controles Material con área táctil mínima de 48 puntos;
- errores con icono, texto y color;
- etiquetas `Semantics` en estados, botones y tarjetas;
- guía manual para TalkBack, fuente ampliada y dos anchos en `docs/semana10/VERIFICACION_MANUAL.md`.

## Uso de IA

Resumen documentado en `docs/semana10/USO_IA.md`.

## Evidencias

La checklist está en `evidence/semana10/CHECKLIST_EVIDENCIAS.md`. Las capturas, TalkBack, fuente ampliada y dos anchos quedan pendientes porque requieren intervención manual.

# Avance 11 — Navegación, manejo de estado y formularios

## Objetivo

Se agregó navegación declarativa, manejo de estado con Riverpod, autenticación en memoria, rutas protegidas, estado remoto cerrado y formulario real de creación de pedidos sin reconstruir el proyecto ni eliminar avances anteriores.

## Navegación con go_router

La configuración vive en `mobile/lib/router/app_router.dart`.

Rutas principales:

- `/login`: pública, consume `POST /api/auth/login`.
- `/products`: pública, consume `GET /api/products`.
- `/products/:id`: anidada y protegida, recibe el ID por URL.
- `/orders`: protegida, consume `GET /api/orders`.
- `/orders/new`: protegida, consume `POST /api/orders`.
- `/profile`: protegida, muestra usuario autenticado y prueba controlada de 403.

`/products/:id` no recibe un objeto completo por `extra`; reconstruye la pantalla desde la URL. Como el backend no tiene `GET /api/products/[id]`, usa el catálogo real y localiza el producto por ID.

## Autenticación y protección

Riverpod mantiene token y usuario autenticado como estado de aplicación durante la sesión actual. Las rutas protegidas redirigen a `/login?from=<destino>` y, tras login exitoso, vuelven al destino interno solicitado. El parámetro `from` se valida para impedir URLs externas.

401 limpia la sesión y muestra que la sesión terminó. 403 conserva la sesión y muestra un mensaje de permisos.

## Estado

El estado efímero permanece local cuando solo afecta una pantalla: búsqueda, filtros visuales y mostrar/ocultar contraseña. El estado de aplicación usa Riverpod: autenticación, catálogo, pedidos y borrador de pedido.

El catálogo usa `RemoteState<T>` con estados cerrados: initial, loading, data, empty y error. `ProductsScreen` lo integra con `StateView` y `ProductCard`.

## Formulario de pedido

`CreateOrderScreen` usa el endpoint real `POST /api/orders`.

Contrato:

```json
{
  "addressId": "uuid",
  "items": [{ "productId": "uuid", "quantity": 1 }]
}
```

Validaciones derivadas del backend:

- `addressId`: UUID requerido.
- `items`: mínimo 1, máximo 30.
- `productId`: UUID requerido.
- `quantity`: entero positivo, máximo 50.

La cantidad valida al abandonar el campo mediante `FocusNode` y valida al enviar con `FormState.validate()`. Los errores 422 se extraen de `errors` y se asocian al campo correspondiente cuando el backend lo permite. El borrador se conserva al navegar y se limpia después de crear correctamente.

## Pruebas y evidencias

Verificación ejecutada:

```powershell
cd mobile
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Resultado:

- `flutter analyze`: No issues found.
- `flutter test`: All tests passed.

Documentación de Semana 11: `docs/semana11/`.

Evidencias: `evidence/semana11/`. Las capturas visuales quedan pendientes de ejecución manual/ADB con backend y emulador activos; no se crearon capturas falsas.

## Uso de IA

El registro está en `docs/semana11/USO_IA.md`.

# Taller - Autenticación, navegación, estado y formularios

La documentación del taller está en `docs/taller_autenticacion/`.

Resumen:

- Login móvil con `POST /api/auth/login`.
- Registro móvil con `POST /api/auth/register`.
- Navegación declarativa con `go_router`.
- Rutas protegidas para pedidos, creación de pedido, perfil y detalle.
- Estado de sesión y formularios con Riverpod.
- Logout desde perfil.
- Pruebas desde `mobile` con `dart format .`, `flutter analyze` y `flutter test`.

No se agregan credenciales ni tokens en esta sección.

## Semana 13 — Integración móvil/backend

Flutter utiliza Dio centralizado con interceptores, refresh automático, serialización generada de Product/OrderSummary y repositorios con caché offline. Incluye outbox, cancelación, reintentos limitados, sesión cifrada, HTTPS en producción y logging PROD desactivado. El diagnóstico 422 está disponible solo en DEV/no release y se prueba también su bloqueo en PROD.

Guía breve: [DOCUMENTO_TALLER](docs/semana13/DOCUMENTO_TALLER.md). Resultados y límites: [RESULTADO_FINAL](docs/semana13/RESULTADO_FINAL.md). Las pruebas distinguen transporte simulado de evidencia Android real.
