import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../services/api_exception.dart';
import '../services/sentry_service.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiServiceProvider));
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  int _sessionRevision = 0;
  @override
  AuthState build() {
    final client = ref.read(apiServiceProvider).client;
    client.onSessionChanged = (session) {
      _sessionRevision++;
      state = session == null
          ? const Unauthenticated()
          : Authenticated(session);
    };
    ref.onDispose(() => client.onSessionChanged = null);
    return const Unauthenticated();
  }

  Future<void> restore() async {
    final revision = _sessionRevision;
    final client = ref.read(apiServiceProvider).client;
    try {
      final session = await client.storage.read();
      if (revision != _sessionRevision) return;
      if (session != null && state is Unauthenticated) {
        SentryService.setAnonymousUser();
        state = Authenticated(session);
      }
    } catch (_) {
      if (revision != _sessionRevision) return;
      state = const Unauthenticated(
        message: 'No fue posible recuperar la sesión guardada.',
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _sessionRevision++;
    state = const AuthLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state = Authenticated(session);
      return true;
    } on ApiException catch (error) {
      state = AuthFailure(
        error.statusCode == 401
            ? 'Correo o contraseña incorrectos.'
            : error.message,
        statusCode: error.statusCode,
      );
      return false;
    } catch (_) {
      state = const AuthFailure('No fue posible iniciar sesión.');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _sessionRevision++;
    state = const AuthLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password);
      state = Authenticated(session);
      return true;
    } on ApiException catch (error) {
      state = AuthFailure(error.message, statusCode: error.statusCode);
      return false;
    } catch (_) {
      state = const AuthFailure('No fue posible registrar la cuenta.');
      return false;
    }
  }

  void logout({String? message}) {
    _sessionRevision++;
    unawaited(
      ref
          .read(apiServiceProvider)
          .client
          .clearSession()
          .catchError((Object _) {}),
    );
    state = Unauthenticated(message: message);
  }

  void handleUnauthorized() {
    _sessionRevision++;
    unawaited(
      ref
          .read(apiServiceProvider)
          .client
          .clearSession()
          .catchError((Object _) {}),
    );
    state = const Unauthenticated(
      message: 'Tu sesión terminó. Inicia sesión nuevamente.',
    );
  }
}
