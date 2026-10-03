import 'package:deliverpuyo_mobile/auth/auth_controller.dart';
import 'package:deliverpuyo_mobile/auth/auth_state.dart';
import 'package:deliverpuyo_mobile/models/auth_session.dart';
import 'package:deliverpuyo_mobile/providers/app_providers.dart';
import 'package:deliverpuyo_mobile/services/api_client.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:deliverpuyo_mobile/storage/session_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'semana13_test.dart' show MemorySession, makeClient, jsonBody;

class UnreadableSession implements SessionStorage {
  @override
  Future<AuthSession?> read() async => throw StateError('storage unavailable');
  @override
  Future<void> write(AuthSession session) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  test('valid credentials authenticate and persist the session', () async {
    final storage = MemorySession()..value = null;
    final client = makeClient((request) async {
      expect(request.path, '/api/auth/login');
      expect(request.data, {
        'email': 'valid@example.invalid',
        'password': 'fixture-password',
      });
      return jsonBody(200, {
        'data': {
          'user': {
            'id': 'user-1',
            'name': 'Usuario de prueba',
            'email': 'valid@example.invalid',
            'role': 'CLIENT',
          },
          'accessToken': 'access-fixture',
          'refreshToken': 'refresh-fixture',
          'expiresInSeconds': 900,
        },
      });
    }, store: storage);
    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(ApiService(client: client)),
      ],
    );
    addTearDown(() {
      container.dispose();
      client.dio.close(force: true);
    });

    final authenticated = await container
        .read(authControllerProvider.notifier)
        .login(email: 'valid@example.invalid', password: 'fixture-password');

    expect(authenticated, isTrue);
    final state = container.read(authControllerProvider);
    expect(state, isA<Authenticated>());
    expect(state.session?.accessToken, 'access-fixture');
    expect((await storage.read())?.user.id, 'user-1');
  });

  test('invalid credentials become a handled authentication failure', () async {
    final client = makeClient((_) async => jsonBody(401));
    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(ApiService(client: client)),
      ],
    );
    addTearDown(() {
      container.dispose();
      client.dio.close(force: true);
    });

    final authenticated = await container
        .read(authControllerProvider.notifier)
        .login(email: 'invalid@example.invalid', password: 'wrong-password');

    expect(authenticated, isFalse);
    final state = container.read(authControllerProvider);
    expect(state, isA<AuthFailure>());
    expect((state as AuthFailure).statusCode, 401);
    expect(state.message, 'Correo o contraseña incorrectos.');
    expect(state.session, isNull);
  });

  test('transport failure becomes a safe authentication failure', () async {
    final client = makeClient(
      (request) async => throw DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(ApiService(client: client)),
      ],
    );
    addTearDown(() {
      container.dispose();
      client.dio.close(force: true);
    });

    final authenticated = await container
        .read(authControllerProvider.notifier)
        .login(email: 'offline@example.invalid', password: 'fixture-password');

    expect(authenticated, isFalse);
    final state = container.read(authControllerProvider);
    expect(state, isA<AuthFailure>());
    expect((state as AuthFailure).statusCode, isNull);
    expect(state.message, 'Sin conexión. Inténtalo nuevamente.');
    expect(state.session, isNull);
  });

  test(
    'restore storage failure stays unauthenticated with safe notice',
    () async {
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(
            ApiService(
              client: ApiClient(storage: UnreadableSession(), logging: false),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.notifier).restore();
      final state = container.read(authControllerProvider);
      expect(state, isA<Unauthenticated>());
      expect(state.session, isNull);
      expect(
        (state as Unauthenticated).message,
        'No fue posible recuperar la sesión guardada.',
      );
    },
  );
}
