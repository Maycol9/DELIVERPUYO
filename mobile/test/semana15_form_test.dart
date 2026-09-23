import 'package:deliverpuyo_mobile/auth/auth_controller.dart';
import 'package:deliverpuyo_mobile/providers/app_providers.dart';
import 'package:deliverpuyo_mobile/screens/create_order_screen.dart';
import 'package:deliverpuyo_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'semana13_form_test.dart' show FormApi;

void main() {
  testWidgets('selected order fields fit a 320 pixel wide screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(FormApi())],
    );
    addTearDown(container.dispose);
    await container
        .read(authControllerProvider.notifier)
        .login(email: 'test@example.invalid', password: 'fixture');
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
    expect(tester.takeException(), isNull);
    await container.read(orderDraftProvider.notifier).flush();
    await tester.pumpWidget(const SizedBox.shrink());
  });
  for (final quantity in ['', '0', '-1']) {
    testWidgets('order form rejects quantity "$quantity" without POST', (
      tester,
    ) async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final api = FormApi();
      final container = ProviderContainer(
        overrides: [apiServiceProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      await container
          .read(authControllerProvider.notifier)
          .login(email: 'test@example.invalid', password: 'fixture');
      container.read(orderDraftProvider.notifier)
        ..setAddress('a')
        ..setProduct('p')
        ..setQuantity(quantity);
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
      await tester.pumpAndSettle();
      await tester.tap(find.text('CREAR PEDIDO'));
      await tester.pumpAndSettle();
      expect(api.posts, 0);
      expect(
        find.text(
          quantity.isEmpty
              ? 'La cantidad es obligatoria.'
              : 'La cantidad debe ser mayor que cero.',
        ),
        findsOneWidget,
      );
      expect(container.read(orderDraftProvider).quantity, quantity);
      await container.read(orderDraftProvider.notifier).flush();
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
