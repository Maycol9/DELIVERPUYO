import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:deliverpuyo_mobile/storage/session_storage.dart';
import 'package:deliverpuyo_mobile/models/app_user.dart';
import 'package:deliverpuyo_mobile/models/auth_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('secure session roundtrip and clear, no password property', () async {
    const store = SecureSessionStorage();
    await store.write(
      const AuthSession(
        user: AppUser(
          id: 'u',
          name: 'Prueba',
          email: 'test@example.invalid',
          role: 'CLIENT',
        ),
        accessToken: 'fixture-access',
        refreshToken: 'fixture-refresh',
        expiresInSeconds: 900,
      ),
    );
    final read = await store.read();
    expect(read!.user.id, 'u');
    expect(read.accessToken, 'fixture-access');
    expect(read.refreshToken, 'fixture-refresh');
    final persisted = await const FlutterSecureStorage().readAll();
    expect(persisted.length, 1);
    expect(persisted.values.single, isNot(contains('password')));
    await store.clear();
    expect(await store.read(), isNull);
  });
  test(
    'corrupt secure session is cleared without exposing technical data',
    () async {
      await const FlutterSecureStorage().write(
        key: 'deliverpuyo.session.v1',
        value: 'invalid-json',
      );
      expect(await const SecureSessionStorage().read(), isNull);
      expect(await const FlutterSecureStorage().readAll(), isEmpty);
    },
  );
}
