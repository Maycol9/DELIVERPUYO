import 'dart:async';
import 'package:deliverpuyo_mobile/models/product.dart';
import 'package:deliverpuyo_mobile/products/product_repository.dart';
import 'package:deliverpuyo_mobile/products/products_controller.dart';
import 'package:deliverpuyo_mobile/screens/products_screen.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:deliverpuyo_mobile/state/remote_state.dart';
import 'package:deliverpuyo_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCatalogRepository extends ProductRepository {
  FakeCatalogRepository()
    : super(ProductRemoteDataSource(ApiService()), ProductLocalDataSource());
  final snapshots = StreamController<ProductSnapshot>.broadcast();
  int requests = 0;
  @override
  Stream<ProductSnapshot> watch() {
    requests++;
    return snapshots.stream;
  }
}

// UI harness: injects repository states without altering the production controller.
// Transport/controller behavior remains covered by the existing repository tests.
class CatalogHarness extends ProductsController {
  CatalogHarness(this.repository);
  final FakeCatalogRepository repository;
  StreamSubscription<ProductSnapshot>? subscription;
  @override
  RemoteState<List<Product>> build() {
    ref.onDispose(() => subscription?.cancel());
    Future.microtask(load);
    return const RemoteLoading();
  }

  @override
  Future<void> load() async {
    unawaited(subscription?.cancel());
    state = const RemoteLoading();
    subscription = repository.watch().listen((snapshot) {
      state = snapshot.error != null
          ? RemoteError(snapshot.error!)
          : snapshot.products.isEmpty
          ? const RemoteEmpty('No hay productos disponibles en este momento.')
          : RemoteData(snapshot.products);
    });
  }
}

void main() {
  for (final scenario in ['loading', 'data', 'empty', 'error']) {
    testWidgets('catalog screen $scenario with fake repository', (
      tester,
    ) async {
      final repository = FakeCatalogRepository();
      addTearDown(repository.snapshots.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsControllerProvider.overrideWith(
              () => CatalogHarness(repository),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const ProductsScreen(),
          ),
        ),
      );
      await tester.pump();
      const product = Product(
        id: 'p',
        name: 'Producto de prueba',
        price: 2,
        stock: 5,
      );
      if (scenario == 'data') {
        repository.snapshots.add(const ProductSnapshot([product]));
      }
      if (scenario == 'empty') {
        repository.snapshots.add(const ProductSnapshot([]));
      }
      if (scenario == 'error') {
        repository.snapshots.add(
          const ProductSnapshot([], error: 'Error de catálogo de prueba'),
        );
      }
      await tester.pump();
      if (scenario == 'loading') {
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Cargando productos...'), findsOneWidget);
      } else {
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        if (scenario == 'data') {
          expect(find.text('Producto de prueba'), findsOneWidget);
        }
        if (scenario == 'empty') {
          expect(find.text('Catálogo vacío'), findsOneWidget);
        }
        if (scenario == 'error') {
          expect(find.text('Error de catálogo de prueba'), findsOneWidget);
          await tester.ensureVisible(find.text('REINTENTAR'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('REINTENTAR'));
          await tester.pump();
          expect(repository.requests, 2);
          repository.snapshots.add(const ProductSnapshot([product]));
          await tester.pumpAndSettle();
          expect(find.text('Producto de prueba'), findsOneWidget);
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
