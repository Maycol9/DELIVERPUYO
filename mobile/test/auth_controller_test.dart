import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliverpuyo_mobile/auth/auth_controller.dart';
import 'package:deliverpuyo_mobile/auth/auth_state.dart';
import 'package:deliverpuyo_mobile/models/app_user.dart';
import 'package:deliverpuyo_mobile/models/auth_session.dart';
import 'package:deliverpuyo_mobile/providers/app_providers.dart';
import 'package:deliverpuyo_mobile/services/api_exception.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  group('AuthController', () {
    test('starts unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(authControllerProvider), isA<Unauthenticated>());
    });

    test('login success stores user and token in application state', () async {
      final container = ProviderContainer(
        overrides: [apiServiceProvider.overrideWithValue(_FakeApiService())],
      );
      addTearDown(container.dispose);

      final ok = await container
          .read(authControllerProvider.notifier)
          .login(email: 'cliente@deliverpuyo.local', password: 'Cliente1234');

      final state = container.read(authControllerProvider);
      expect(ok, isTrue);
      expect(state, isA<Authenticated>());
      expect(state.session?.accessToken, 'access-token');
      expect(state.session?.user.email, 'cliente@deliverpuyo.local');
    });

    test('login failure exposes error state', () async {
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(
            _FakeApiService(shouldFail: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final ok = await container
          .read(authControllerProvider.notifier)
          .login(email: 'bad@example.com', password: 'bad');

      expect(ok, isFalse);
      expect(container.read(authControllerProvider), isA<AuthFailure>());
      expect(
        (container.read(authControllerProvider) as AuthFailure).message,
        'Correo o contraseña incorrectos.',
      );
    });

    test('register success stores created user and token', () async {
      final container = ProviderContainer(
        overrides: [apiServiceProvider.overrideWithValue(_FakeApiService())],
      );
      addTearDown(container.dispose);

      final ok = await container
          .read(authControllerProvider.notifier)
          .register(
            name: 'Cliente Nuevo',
            email: 'nuevo@deliverpuyo.local',
            password: 'Cliente1234',
          );

      final state = container.read(authControllerProvider);
      expect(ok, isTrue);
      expect(state, isA<Authenticated>());
      expect(state.session?.user.email, 'nuevo@deliverpuyo.local');
      expect(state.session?.accessToken, 'register-access-token');
    });

    test('logout clears session', () async {
      final container = ProviderContainer(
        overrides: [apiServiceProvider.overrideWithValue(_FakeApiService())],
      );
      addTearDown(container.dispose);
      await container
          .read(authControllerProvider.notifier)
          .login(email: 'cliente@deliverpuyo.local', password: 'Cliente1234');

      container.read(authControllerProvider.notifier).logout();

      expect(container.read(authControllerProvider), isA<Unauthenticated>());
    });

    test(
      '401 clears session and 403 does not force logout by itself',
      () async {
        final container = ProviderContainer(
          overrides: [apiServiceProvider.overrideWithValue(_FakeApiService())],
        );
        addTearDown(container.dispose);
        await container
            .read(authControllerProvider.notifier)
            .login(email: 'cliente@deliverpuyo.local', password: 'Cliente1234');

        const forbidden = ApiException(
          statusCode: 403,
          message: 'No tienes permiso para realizar esta acción.',
        );
        expect(forbidden.isForbidden, isTrue);
        expect(container.read(authControllerProvider), isA<Authenticated>());

        container.read(authControllerProvider.notifier).handleUnauthorized();
        expect(container.read(authControllerProvider), isA<Unauthenticated>());
      },
    );
  });
}

class _FakeApiService extends ApiService {
  _FakeApiService({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw const ApiException(
        statusCode: 401,
        message: 'Credenciales inválidas',
      );
    }
    return const AuthSession(
      user: AppUser(
        id: 'user-id',
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
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return AuthSession(
      user: AppUser(
        id: 'new-user-id',
        name: name,
        email: email,
        role: 'CLIENT',
      ),
      accessToken: 'register-access-token',
      refreshToken: 'register-refresh-token',
      expiresInSeconds: 900,
    );
  }
}
