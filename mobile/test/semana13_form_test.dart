import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deliverpuyo_mobile/auth/auth_controller.dart';
import 'package:deliverpuyo_mobile/auth/auth_state.dart';
import 'package:deliverpuyo_mobile/models/auth_session.dart';
import 'package:deliverpuyo_mobile/models/app_user.dart';
import 'package:deliverpuyo_mobile/models/address.dart';
import 'package:deliverpuyo_mobile/models/order.dart';
import 'package:deliverpuyo_mobile/models/product.dart';
import 'package:deliverpuyo_mobile/providers/app_providers.dart';
import 'package:deliverpuyo_mobile/screens/create_order_screen.dart';
import 'package:deliverpuyo_mobile/services/api_exception.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:deliverpuyo_mobile/theme/app_theme.dart';

class FormApi extends ApiService {
  int posts = 0;
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async => const AuthSession(
    user: AppUser(
      id: 'u',
      name: 'Prueba',
      email: 'test@example.invalid',
      role: 'CLIENT',
    ),
    accessToken: 'fake-only',
    refreshToken: 'fake-only',
    expiresInSeconds: 900,
  );
  @override
  Future<List<Address>> getAddresses(String token) async => [
    const Address(id: 'a', label: 'Casa', address: 'Dirección de prueba'),
  ];
  @override
  Future<ProductListResult> getProducts() async => ProductListResult.success([
    const Product(id: 'p', name: 'Pan', price: 2, stock: 10),
  ]);
  @override
  Future<List<OrderSummary>> getOrders(String token) async => [];
  @override
  Future<OrderSummary> createOrder({
    required String token,
    required OrderDraft draft,
  }) async {
    posts++;
    throw ApiException.fromStatus(
      422,
      errors: {
        'items': ['Cantidad rechazada por el servidor'],
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets(
    '422 server field error rendered on form, draft and auth retained',
    (tester) async {
      final api = FormApi();
      final container = ProviderContainer(
        overrides: [apiServiceProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      await container
          .read(authControllerProvider.notifier)
          .login(email: 'test@example.invalid', password: 'test-fixture');
      container.read(orderDraftProvider.notifier)
        ..setAddress('a')
        ..setProduct('p')
        ..setQuantity('2');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const CreateOrderScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('CREAR PEDIDO'));
      await tester.tap(find.text('CREAR PEDIDO'));
      await tester.pumpAndSettle();
      expect(api.posts, 1);
      expect(find.text('Cantidad rechazada por el servidor'), findsWidgets);
      expect(container.read(orderDraftProvider).quantity, '2');
      expect(container.read(authControllerProvider), isA<Authenticated>());
    },
  );
}
