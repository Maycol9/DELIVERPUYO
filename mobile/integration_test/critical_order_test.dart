import 'package:deliverpuyo_mobile/addresses/addresses_provider.dart';
import 'package:deliverpuyo_mobile/auth/auth_controller.dart';
import 'package:deliverpuyo_mobile/auth/auth_state.dart';
import 'package:deliverpuyo_mobile/main.dart';
import 'package:deliverpuyo_mobile/models/address.dart';
import 'package:deliverpuyo_mobile/providers/app_providers.dart';
import 'package:deliverpuyo_mobile/router/app_router.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:deliverpuyo_mobile/state/remote_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test/semana13_test.dart' show MemorySession, makeClient, jsonBody;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'critical: open app, login, catalog, select product, create order',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      var logins = 0;
      var posts = 0;
      var addressRequests = 0;
      var authorizedRequests = true;
      const product = {
        'id': 'p',
        'name': 'Producto E2E',
        'price': 2,
        'stock': 10,
      };
      const order = {
        'id': 'e2e-order',
        'status': 'PENDING',
        'total': 4,
        'createdAt': '2026-09-22',
      };
      final client = makeClient((request) async {
        if (request.path == '/api/auth/login' && request.method == 'POST') {
          logins++;
          expect(request.data, {
            'email': 'e2e@example.invalid',
            'password': 'fixture-only',
          });
          return jsonBody(200, {
            'data': {
              'user': {
                'id': 'e2e-user',
                'name': 'Prueba',
                'email': 'e2e@example.invalid',
                'role': 'CLIENT',
              },
              'accessToken': 'fixture-access',
              'refreshToken': 'fixture-refresh',
              'expiresInSeconds': 900,
            },
          });
        }
        if (request.path == '/api/products') {
          return jsonBody(200, {
            'data': [product],
          });
        }
        authorizedRequests =
            authorizedRequests &&
            request.headers['Authorization'] == 'Bearer fixture-access';
        if (request.path == '/api/addresses') {
          addressRequests++;
          return jsonBody(200, {
            'data': [
              {'id': 'a', 'label': 'Prueba', 'address': 'Destino sintético'},
            ],
          });
        }
        if (request.path == '/api/orders') {
          if (request.method == 'POST') {
            posts++;
            expect(request.data, {
              'addressId': 'a',
              'items': [
                {'productId': 'p', 'quantity': 2},
              ],
            });
            return jsonBody(201, {'data': order});
          }
          return jsonBody(200, {
            'data': posts == 0 ? [] : [order],
          });
        }
        throw StateError('Unexpected HTTP operation in controlled E2E');
      }, store: MemorySession()..value = null);
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(ApiService(client: client)),
        ],
      );
      final router = container.read(appRouterProvider);
      addTearDown(() {
        router.dispose();
        container.dispose();
        client.dio.close(force: true);
      });
      await container.read(authControllerProvider.notifier).restore();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const DeliverPuyoApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('DeliverPuyo'), findsOneWidget);
      await tester.tap(find.byTooltip('Pedidos'));
      await tester.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo electrónico'),
        'e2e@example.invalid',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'fixture-only',
      );
      await tester.tap(find.text('INGRESAR'));
      await tester.pumpAndSettle();
      expect(logins, 1);
      expect(container.read(authControllerProvider), isA<Authenticated>());
      await tester.tap(find.byTooltip('Productos'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Producto E2E'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Producto E2E'));
      await tester.pumpAndSettle();
      expect(find.text('Detalle del producto'), findsOneWidget);
      await tester.tap(find.text('CREAR PEDIDO'));
      await tester.pumpAndSettle();
      // On a device, settling animations does not wait for HTTP decoding.
      for (var attempt = 0; attempt < 100; attempt++) {
        if (!container.read(addressesProvider).isLoading) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 100));
      }
      final addressState = container.read(addressesProvider).valueOrNull;
      expect(addressRequests, 1);
      expect(authorizedRequests, isTrue);
      expect(
        addressState,
        isA<RemoteData<List<Address>>>(),
        reason: addressState is RemoteError<List<Address>>
            ? addressState.message
            : null,
      );
      expect(
        (addressState as RemoteData<List<Address>>).value.single.address,
        'Destino sintético',
      );
      final addressDropdown = find.byType(DropdownButton<String>).at(0);
      await tester.ensureVisible(addressDropdown);
      await tester.pumpAndSettle();
      await tester.tap(addressDropdown);
      await tester.pumpAndSettle();
      expect(find.text('Prueba - Destino sintético'), findsWidgets);
      await tester.tap(find.text('Prueba - Destino sintético').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text(r'Producto E2E - $2.00').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cantidad'),
        '2',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('CREAR PEDIDO'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CREAR PEDIDO'));
      await tester.pumpAndSettle();
      expect(posts, 1);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/orders');
      expect(find.text('Pedido e2e-orde'), findsOneWidget);
      expect(container.read(orderDraftProvider).isEmpty, isTrue);
      await container.read(orderDraftProvider.notifier).flush();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
