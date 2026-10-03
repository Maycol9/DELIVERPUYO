import '../models/auth_session.dart';

sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is Authenticated;
  AuthSession? get session =>
      this is Authenticated ? (this as Authenticated).session : null;
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  const Authenticated(this.session, {this.notice});

  @override
  final AuthSession session;
  final String? notice;
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({this.message});

  final String? message;
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}
