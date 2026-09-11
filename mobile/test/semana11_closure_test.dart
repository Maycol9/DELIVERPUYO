import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliverpuyo_mobile/auth/auth_controller.dart';
import 'package:deliverpuyo_mobile/auth/auth_state.dart';
import 'package:deliverpuyo_mobile/models/app_user.dart';
import 'package:deliverpuyo_mobile/models/auth_session.dart';
import 'package:deliverpuyo_mobile/models/order.dart';
import 'package:deliverpuyo_mobile/models/product.dart';
import 'package:deliverpuyo_mobile/orders/orders_controller.dart';
import 'package:deliverpuyo_mobile/providers/app_providers.dart';
import 'package:deliverpuyo_mobile/router/app_router.dart';
import 'package:deliverpuyo_mobile/screens/login_screen.dart';
import 'package:deliverpuyo_mobile/screens/product_detail_screen.dart';
import 'package:deliverpuyo_mobile/services/api_exception.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:deliverpuyo_mobile/state/remote_state.dart';
import 'package:deliverpuyo_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('ProductDetailScreen rebuilds from the route id without extra', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiServiceProvider.overrideWithValue(_ClosureFakeApi())],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ProductDetailScreen(productId: 'product-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Producto por ID'), findsOneWidget);
    expect(find.text(r'$4.25'), findsOneWidget);
    expect(find.text('CREAR PEDIDO'), findsOneWidget);
  });

  testWidgets('go_router redirects protected route to login preserving from', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(_ClosureFakeApi())],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );

    router.go('/orders');
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    expect(
      router.routerDelegate.currentConfiguration.uri.queryParameters['from'],
      '/orders',
    );
  });

  testWidgets('login form validates email and password with clear messages', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiServiceProvider.overrideWithValue(_ClosureFakeApi())],
        child: MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
      ),
    );

    await tester.tap(find.text('INGRESAR'));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      'correo-invalido',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'secreto',
    );
    await tester.tap(find.text('INGRESAR'));
    await tester.pump();

    expect(find.text('Ingresa un correo electrónico válido.'), findsOneWidget);
  });

  testWidgets('login success returns to the intended protected destination', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(_ClosureFakeApi())],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );

    router.go('/orders');
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      'cliente@deliverpuyo.local',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'Cliente1234',
    );
    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/orders');
    expect(container.read(authControllerProvider), isA<Authenticated>());
  });

  test('logout blocks protected routes again', () async {
    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(_ClosureFakeApi())],
    );
    addTearDown(container.dispose);

    await container
        .read(authControllerProvider.notifier)
        .login(email: 'cliente@deliverpuyo.local', password: 'secret');
    container.read(authControllerProvider.notifier).logout();

    expect(container.read(authControllerProvider), isA<Unauthenticated>());
  });

  test('422 extracts field errors and keeps the order draft values', () async {
    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(
          _ClosureFakeApi(createOrderStatusCode: 422),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(authControllerProvider.notifier)
        .login(email: 'cliente@deliverpuyo.local', password: 'secret');
    container.read(orderDraftProvider.notifier)
      ..setAddress('550e8400-e29b-41d4-a716-446655440000')
      ..setProduct('550e8400-e29b-41d4-a716-446655440001')
      ..setQuantity('2');

    final draftBefore = container.read(orderDraftProvider);
    final result = await container
        .read(ordersControllerProvider.notifier)
        .create(draftBefore);

    expect(result.success, isFalse);
    expect(result.statusCode, 422);
    expect(
      result.fieldErrors['items'],
      'No repita productos dentro del mismo pedido',
    );
    expect(container.read(orderDraftProvider).addressId, draftBefore.addressId);
    expect(container.read(orderDraftProvider).productId, draftBefore.productId);
    expect(container.read(orderDraftProvider).quantity, draftBefore.quantity);
  });

  test(
    '403 keeps AuthSession, token, user and exposes permission message',
    () async {
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(
            _ClosureFakeApi(listOrdersStatusCode: 403),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .login(email: 'cliente@deliverpuyo.local', password: 'secret');
      final sessionBefore = container.read(authControllerProvider).session!;

      await container.read(ordersControllerProvider.notifier).load();

      final authState = container.read(authControllerProvider);
      final ordersState = container.read(ordersControllerProvider);
      expect(authState, isA<Authenticated>());
      expect(authState.session?.accessToken, sessionBefore.accessToken);
      expect(authState.session?.user.email, sessionBefore.user.email);
      expect(ordersState, isA<RemoteError<List<OrderSummary>>>());
      expect(
        (ordersState as RemoteError<List<OrderSummary>>).message,
        'No tienes permiso para realizar esta acción.',
      );
    },
  );

  test('401 clears session and leaves router able to show login', () async {
    final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(_ClosureFakeApi())],
    );
    addTearDown(container.dispose);

    await container
        .read(authControllerProvider.notifier)
        .login(email: 'cliente@deliverpuyo.local', password: 'secret');
    container.read(authControllerProvider.notifier).handleUnauthorized();

    expect(container.read(authControllerProvider), isA<Unauthenticated>());
  });
}

class _ClosureFakeApi extends ApiService {
  _ClosureFakeApi({this.createOrderStatusCode, this.listOrdersStatusCode});

  final int? createOrderStatusCode;
  final int? listOrdersStatusCode;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return const AuthSession(
      user: AppUser(
        id: 'user-1',
        name: 'Cliente de Prueba',
        email: 'cliente@deliverpuyo.local',
        role: 'CLIENT',
      ),
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      expiresInSeconds: 900,
    );
  }

  @override
  Future<ProductListResult> getProducts() async {
    return ProductListResult.success([
      const Product(
        id: 'product-1',
        name: 'Producto por ID',
        price: 4.25,
        stock: 8,
        categoryName: 'Bebidas',
      ),
    ]);
  }

  @override
  Future<List<OrderSummary>> getOrders(String token) async {
    if (listOrdersStatusCode != null) {
      throw ApiException.fromStatus(listOrdersStatusCode!);
    }
    return const [];
  }

  @override
  Future<OrderSummary> createOrder({
    required String token,
    required OrderDraft draft,
  }) async {
    if (createOrderStatusCode != null) {
      throw ApiException.fromStatus(
        createOrderStatusCode!,
        serverMessage: 'Datos del pedido inválidos',
        errors: const {
          'items': ['No repita productos dentro del mismo pedido'],
        },
      );
    }
    return const OrderSummary(
      id: 'order-1',
      status: 'PENDING',
      total: 6.5,
      createdAt: '2026-08-29T00:00:00.000Z',
    );
  }
}
