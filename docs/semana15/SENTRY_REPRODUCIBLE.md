# Sentry reproducible — DeliverPuyo

## Estado verificado

Migración de `sentry_flutter ^8.14.2` a `^9.30.1`, resuelta a 9.30.1 en
`mobile/pubspec.lock`. No se considera cerrado el APK: Windows Defender bloquea
la escritura de AAPT2 en la carpeta protegida Documents.

## Compatibilidad y fuentes

- [pub.dev: sentry_flutter](https://pub.dev/packages/sentry_flutter): estable 9.30.1.
- [API oficial de la versión](https://pub.dev/api/packages/sentry_flutter/versions/9.30.1):
  Dart >=3.5.0 <4.0.0 y Flutter >=3.24.0.
- [Changelog oficial](https://pub.dev/packages/sentry_flutter/changelog):
  9.28.0 añadió soporte para Kotlin integrado de AGP 9; 9.3.0 actualizó el
  languageVersion de Kotlin. El build.gradle publicado de 9.30.1 ya no fuerza
  el languageVersion 1.6 del paquete 8.14.2.
- SDK local comprobado: Flutter 3.44.4 / Dart 3.12.2.
- Sin cambios en Kotlin 2.3.20, AGP 9.4.0, Gradle 9.6.0, JDK 17,
  compileSdk 37 ni targetSdk 36.

La documentación no garantiza expresamente toda esta combinación exacta.
El análisis y las pruebas Dart pasan; la compatibilidad completa del APK queda
pendiente del build, actualmente bloqueado por Windows Defender.

Verificación adicional: `gradlew.bat :sentry_flutter:compileDebugKotlin
--rerun-tasks --console=plain` terminó con **BUILD SUCCESSFUL in 32s**, 26 tareas
ejecutadas. Esto fuerza la recompilación del plugin oficial y confirma que su
código Kotlin compila en este proyecto sin el parche anterior. No equivale a
un APK completo. Persisten avisos de deprecación por la configuración existente
`android.builtInKotlin=false` y `android.newDsl=false`; no se modificaron.

## Caché oficial, sin parches

Se restauró únicamente `sentry_flutter-8.14.2/android/build.gradle` con los bytes
del archivo oficial, comprobando primero el SHA-256 del archivo comprimido.
No se borró el pub cache ni se ejecutó `flutter pub cache repair`.

Comparación posterior, byte a byte con los archivos oficiales de pub.dev:

| Paquete | Resultado | SHA-256 del archivo comprimido oficial |
|---|---|---|
| sentry_flutter 8.14.2 | build.gradle restaurado coincide | 5ba2cf40646a77d113b37a07bd69f61bb3ec8a73cbabe5537b05a7c89d2656f8 |
| sentry_flutter 9.30.1 | 488 archivos coinciden | bdd8897b38ce31185c42ed910628059c4eccbc0b0641213e8d1c63e2fda3f5a3 |
| sentry 9.30.1 | 410 archivos coinciden | 40a247686af64e497df29ab0de1303a20ca55a2e3c7c7e39b989fac47dcadf84 |

Los archivos comprimidos se compararon en memoria. No hay dependencia de
archivos temporales externos ni de modificaciones manuales en pub/Gradle cache.
El uso habitual de las cachés del gestor de dependencias sí permanece.

## Ajustes en el proyecto

- pubspec y lockfile: Sentry 9.30.1; resolución transitiva de jni 0.14.2 y
  path_provider_android 2.2.23, eliminando jni_flutter y jni_util.
- `enable-linux-desktop: false` en la configuración del proyecto evita que
  pub get intente crear enlaces de plugins Linux en Windows sin Developer Mode.
  Esto deshabilita el destino Linux en este proyecto; el objetivo validado es Android.
- API revisada en main, configuración, privacidad, servicio e interceptor Dio.
  Se conservan DSN por dart-define, beforeSend, usuario identificado por hash y
  breadcrumbs con metadatos limitados. Un hash de usuario es un seudónimo;
  no garantiza anonimato frente a alguien que conozca los identificadores.
- Sentry 9 incorpora canales independientes de logs y métricas. Se deshabilitan
  y se descartan mediante sus callbacks para que no eludan beforeSend.
- Tres pruebas nuevas comprueban opciones, descarte de logs/métricas y
  filtrado de dirección/coordenadas conservando versión y stack trace.

Los filtros existentes se conservan. La validación es local con datos sintéticos:
no se proporcionó DSN real ni se enviaron eventos. Los filtros por clave/patrón
no equivalen a reconocer cualquier dirección o coordenada dentro de texto libre.

## Validación ejecutada

| Comando desde mobile | Resultado |
|---|---|
| flutter clean | OK |
| flutter pub get | OK después del ajuste de destinos de escritorio |
| dart format lib test | OK, 70 archivos |
| flutter analyze | No issues found! |
| flutter test --reporter expanded | 123 passed, 1 skipped, 0 failures |
| flutter build apk --debug | FALLÓ: processDebugResources / AAPT2 bloqueado por Defender |

Defender registró evento 1123 a las 2026-09-23T00:59:16Z:

```text
Proceso bloqueado:
C:\Users\Maycol Perez\.gradle\caches\9.6.0\transforms\561cbc3c5e4bf86b3a494c4e655459cd\transformed\aapt2-9.4.0-15978811-windows\aapt2.exe

Destino de escritura:
mobile\build\app\intermediates\stable_resource_ids_file\debug\processDebugResources\

Error del build:
stableIds.txt: failed to open: El sistema no puede encontrar el archivo especificado. (2).
BUILD FAILED in 1m 52s
```

No se desactivó Defender ni se agregó una excepción sin autorización.
Es necesario permitir la herramienta de compilación en el acceso controlado a
carpetas y volver a ejecutar `flutter build apk --debug` antes de declarar éxito.
APK esperado, todavía no validado: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.

## Git y pendientes

Se consultaron `git status --short` y `git diff --stat`. El árbol ya contenía
cambios preparados y sin preparar de trabajos anteriores; se conservaron.
Los cambios de implementación de esta migración están dentro del proyecto.
La única restauración externa fue el archivo del paquete antiguo descrito arriba.
Sin commit y sin push. Sin cambios en backend.

Pendientes: desbloqueo de AAPT2, APK exitoso, DSN real, fallo controlado y revisión
del evento en Sentry. No declarar reproducibilidad completa mientras falle el APK.
