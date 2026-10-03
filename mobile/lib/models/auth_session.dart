import 'app_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
  });

  final AppUser user;
  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
}
