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
