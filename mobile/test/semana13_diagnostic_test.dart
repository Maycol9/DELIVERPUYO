import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliverpuyo_mobile/auth/auth_controller.dart';
import 'package:deliverpuyo_mobile/auth/auth_state.dart';
import 'package:deliverpuyo_mobile/config/api_config.dart';
import 'package:deliverpuyo_mobile/models/order.dart';
import 'package:deliverpuyo_mobile/orders/order_repository.dart';
import 'package:deliverpuyo_mobile/providers/app_providers.dart';
import 'package:deliverpuyo_mobile/screens/create_order_screen.dart';
import 'package:deliverpuyo_mobile/services/api_exception.dart';
import 'semana13_form_test.dart' show FormApi;

class DiagnosticApi extends FormApi {
  OrderDraft? sent;
  @override
  Future<OrderSummary> createOrder({
    required String token,
    required OrderDraft draft,
  }) {
    sent = draft;
    return super.createOrder(token: token, draft: draft);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('diagnostic DEV field error or PROD hidden and blocked', (
    tester,
  ) async {
    final api = DiagnosticApi();
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
      ..setQuantity('1');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CreateOrderScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.text('Probar validación backend 422 (DEV)');
    if (ApiConfig.loggingEnabled) {
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(api.posts, 1);
      expect(api.sent!.quantity, '0');
      expect(find.text('Cantidad rechazada por el servidor'), findsOneWidget);
      expect(container.read(orderDraftProvider).quantity, '1');
      expect(container.read(orderDraftProvider).addressId, 'a');
      expect(container.read(authControllerProvider), isA<Authenticated>());
    } else {
      expect(button, findsNothing);
      await expectLater(
        OrderRepository(
          api,
          OrderLocalDataSource(),
        ).probeValidationDev('u', '', container.read(orderDraftProvider)),
        throwsA(isA<ApiException>()),
      );
      expect(api.posts, 0);
    }
  });

  test(
    'DEV diagnostic never queues or substitutes an existing pending order',
    () async {
      final api = DiagnosticApi();
      final local = OrderLocalDataSource();
      const pending = OrderDraft(
        addressId: 'other',
        productId: 'other',
        quantity: '2',
      );
      await local.write('u', pending, 'pending');
      final repository = OrderRepository(api, local);
      await expectLater(
        repository.probeValidationDev(
          'u',
          '',
          const OrderDraft(addressId: 'a', productId: 'p', quantity: '1'),
        ),
        throwsA(isA<ApiException>()),
      );
      expect(api.posts, ApiConfig.loggingEnabled ? 1 : 0);
      if (ApiConfig.loggingEnabled) {
        expect(api.sent!.addressId, 'a');
        expect(api.sent!.quantity, '0');
      }
      expect((await local.read('u'))!['quantity'], '2');
      expect((await local.read('u'))!['status'], 'pending');
    },
  );
}
