import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../services/api_exception.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiServiceProvider));
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const Unauthenticated();

  Future<bool> login({required String email, required String password}) async {
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
    state = Unauthenticated(message: message);
  }

  void handleUnauthorized() {
    state = const Unauthenticated(
      message: 'Tu sesión terminó. Inicia sesión nuevamente.',
    );
  }
}
