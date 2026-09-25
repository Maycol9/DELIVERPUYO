# Auditoría inicial — Semana 14

## Estado verificado del proyecto

### 1) Cámara existente
- Sí existe soporte nativo para cámara en la app móvil.
- El proyecto ya incluye `image_picker` en [mobile/pubspec.yaml](mobile/pubspec.yaml), y el servicio nativo en [mobile/lib/services/order_native_service.dart](mobile/lib/services/order_native_service.dart) usa `ImagePicker().pickImage(source: camera ? ImageSource.camera : ImageSource.gallery)`.
- La UI ya ofrece acciones de cámara y selector en [mobile/lib/widgets/order_native_section.dart](mobile/lib/widgets/order_native_section.dart), con flujo de permisos, explicación previa y degradación cuando no se concede acceso.

### 2) Selector de fotos
- Sí existe selector de fotos del sistema.
- Se usa `ImageSource.gallery` y se evita una solicitud amplia de galería; la selección es opcional.
- El cancelado de picker no se trata como error, y la imagen se guarda localmente si el usuario confirma.

### 3) Ubicación existente
- Sí existe soporte de ubicación actual en la app móvil.
- Se usa `geolocator` y `permission_handler` en [mobile/pubspec.yaml](mobile/pubspec.yaml) y `Permission.locationWhenInUse` en [mobile/lib/services/order_native_service.dart](mobile/lib/services/order_native_service.dart).
- La sección de pedido ya ofrece botón para usar ubicación actual y guarda `OrderLocation` en el borrador local.

### 4) Plugins actuales
- `image_picker` ^1.2.3
- `geolocator` ^14.0.3
- `permission_handler` ^13.0.2
- `path_provider` ^2.1.6
- `flutter_secure_storage` ^11.1.0
- `shared_preferences` ^2.5.5
- `flutter_riverpod`, `go_router`, `dio`, `json_annotation`

### 5) Android Manifest
- El archivo [mobile/android/app/src/main/AndroidManifest.xml](mobile/android/app/src/main/AndroidManifest.xml) ya declara:
  - `android.permission.CAMERA`
  - `android.permission.ACCESS_COARSE_LOCATION`
  - `android.permission.ACCESS_FINE_LOCATION`
- No se observan permisos prohibidos como `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES` ni `ACCESS_BACKGROUND_LOCATION`.
- La configuración ya incluye `android:allowBackup="false"` y `networkSecurityConfig`.

### 6) iOS Info.plist
- El archivo [mobile/ios/Runner/Info.plist](mobile/ios/Runner/Info.plist) ya incluye:
  - `NSCameraUsageDescription` con el texto solicitado.
  - `NSLocationWhenInUseUsageDescription` con el texto solicitado.
  - `NSPhotoLibraryUsageDescription` como ayuda para elegir una foto opcional.
- No se observa uso de permisos de ubicación en segundo plano.

### 7) Target API
- El proyecto ya define `targetSdk = 36` en [mobile/android/app/build.gradle.kts](mobile/android/app/build.gradle.kts).
- Este valor ya cumple con la confirmación solicitada: Android 16 / API 36.

### 8) Backend foto
- El backend actual no soporta foto ni evidencia dentro del contrato de `POST /api/orders`.
- En [validations/orders.ts](validations/orders.ts) el esquema acepta solo `addressId` e `items`.
- En [prisma/schema.prisma](prisma/schema.prisma) no hay modelo ni campo para adjuntar archivo o evidencia a una orden.
- Por lo tanto, la foto se gestiona como dato local opcional del borrador y no se envía al backend en este cierre.

### 9) Backend ubicación
- El backend sí soporta coordenadas en direcciones, no en pedidos.
- En [prisma/schema.prisma](prisma/schema.prisma), `Address` tiene `latitude` y `longitude`.
- En [pages/api/addresses/index.ts](pages/api/addresses/index.ts) se expone la lectura de latitud/longitud.
- Pero el contrato de [validations/orders.ts](validations/orders.ts) y [pages/api/orders/index.ts](pages/api/orders/index.ts) solo acepta `addressId` y `items`.
- No se ha detectado soporte real para guardar `latitude` o `longitude` como campos del pedido.

### 10) Persistencia local
- La persistencia local ya está implementada en [mobile/lib/providers/app_providers.dart](mobile/lib/providers/app_providers.dart) y [mobile/lib/orders/evidence_store.dart](mobile/lib/orders/evidence_store.dart).
- `OrderDraft` almacena `photo` y `location` localmente y se persiste por usuario.
- La evidencia se guarda en almacenamiento local del dispositivo, no en base de datos ni en backend.

### 11) Outbox
- Sí existe outbox local para pedidos pendientes.
- La lógica está implementada en [mobile/lib/orders/order_repository.dart](mobile/lib/orders/order_repository.dart), con `FlutterSecureStorage` y estados de `pending` / `sending`.
- No se reenvía automáticamente un pedido ambiguo para evitar duplicados, respetando la política del backend actual.

### 12) OrderDraft
- El modelo ya incluye `photo` y `location` en [mobile/lib/models/order.dart](mobile/lib/models/order.dart) y [mobile/lib/models/order_evidence.dart](mobile/lib/models/order_evidence.dart).
- `OrderDraft` ya serializa `toLocalJson()` para persistencia local y tiene `isEmpty`, `copyWith`, etc.

### 13) Cambios necesarios
- La parte móvil ya está implementada de forma avanzada para la Semana 14.
- Lo que queda como requisito de cierre es validación formal, documentación de privacidad/permisos, y confirmar que no se inventa soporte backend adicional.
- No se debe tocar el backend ni la base de datos para este prototipo; la foto y la ubicación se mantienen como datos opcionales locales del pedido.

## Conclusión técnica

La app móvil ya tiene una implementación real de cámara, selector de fotos y ubicación según el prototipo actual. La auditoría confirma que:

- los permisos requeridos son los mínimos necesarios;
- la ubicación es solo cuando la app está en uso;
- el backend no soporta todavía foto ni coordenadas del pedido;
- la persistencia local y el outbox ya están en funcionamiento;
- el target Android actual es 36 y no se baja la API.

Esto deja la Semana 14 en una etapa de validación y documentación técnica, no de ampliación de contrato backend.