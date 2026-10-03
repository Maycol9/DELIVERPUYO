import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_session.dart';
import '../models/app_user.dart';

abstract interface class SessionStorage {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

class SecureSessionStorage implements SessionStorage {
  const SecureSessionStorage();
  static const _storage = FlutterSecureStorage();
  static const _key = 'deliverpuyo.session.v1';
  @override
  Future<AuthSession?> read() async {
    final value = await _storage.read(key: _key);
    if (value == null) return null;
    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return AuthSession(
        user: AppUser.fromJson(json['user']),
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        expiresInSeconds: json['expiresInSeconds'],
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(AuthSession session) => _storage.write(
    key: _key,
    value: jsonEncode({
      'user': {
        'id': session.user.id,
        'name': session.user.name,
        'email': session.user.email,
        'role': session.user.role,
      },
      'accessToken': session.accessToken,
      'refreshToken': session.refreshToken,
      'expiresInSeconds': session.expiresInSeconds,
    }),
  );
  @override
  Future<void> clear() => _storage.delete(key: _key);
}
