import 'package:flutter/material.dart';
import 'package:deliverpuyo_mobile/config/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:deliverpuyo_mobile/main.dart';
import 'package:deliverpuyo_mobile/providers/app_providers.dart';
import 'package:deliverpuyo_mobile/products/product_repository.dart';
import 'package:deliverpuyo_mobile/products/products_controller.dart';
import 'package:deliverpuyo_mobile/router/app_router.dart';
import 'package:deliverpuyo_mobile/models/product.dart';
import 'package:deliverpuyo_mobile/state/remote_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android: API real, catálogo, caché y almacenamiento seguro', (
    tester,
  ) async {
    final container = ProviderContainer();
    final api = container.read(apiServiceProvider);
    final result = await api.getProducts();
    expect(result.success, isTrue);
    expect(result.products, isNotEmpty);
    final local = ProductLocalDataSource();
    await local.write(result.products);
    expect((await local.read())!.first.id, result.products.first.id);
    const storage = FlutterSecureStorage();
    const probeKey = 'deliverpuyo.verification.nonsecret';
    try {
      await storage.write(key: probeKey, value: 'storage-roundtrip');
      expect(await storage.read(key: probeKey), 'storage-roundtrip');
    } finally {
      await storage.delete(key: probeKey);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DeliverPuyoApp(),
      ),
    );
    await container.read(productsControllerProvider.notifier).load();
    await tester.pumpAndSettle();
    expect(
      container.read(productsControllerProvider),
      isA<RemoteData<List<Product>>>(),
    );
    expect(find.text('DeliverPuyo'), findsOneWidget);
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('09_online_catalogo');
    container.read(appRouterProvider).go('/login');
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
    await binding.takeScreenshot('01_login');
    container.read(appRouterProvider).go('/products');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02_productos_backend_real');
    var prodRejectsHttp = false;
    try {
      ApiConfig.validate(url: 'http://10.0.2.2:3000', ambiente: 'prod');
    } on StateError {
      prodRejectsHttp = true;
    }
    expect(prodRejectsHttp, isTrue);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Verificación de seguridad')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'PRUEBA REAL EN ANDROID\n\n'
              'Almacenamiento seguro: escritura y lectura correctas.\n\n'
              'HTTP rechazado en prod: $prodRejectsHttp\n\n'
              'Ambiente actual: ${ApiConfig.environment}\n\n'
              'API pública: ${ApiConfig.baseUrl}\n\n'
              'No se muestran credenciales.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await binding.takeScreenshot('12_seguridad_configuracion');
  });
}
