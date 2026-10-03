import 'package:flutter_test/flutter_test.dart';
import 'package:deliverpuyo_mobile/config/sentry_config.dart';
import 'package:deliverpuyo_mobile/config/api_config.dart';

void main() {
  group('SentryConfig', () {
    test('DSN defaults to empty string when not provided', () {
      expect(SentryConfig.dsn, isEmpty);
    });

    test('isEnabled is false when DSN is empty', () {
      expect(SentryConfig.isEnabled, isFalse);
    });

    test('testMode defaults to false when not provided', () {
      expect(SentryConfig.testMode, isFalse);
    });

    test('crashEnabled is false when testMode is false', () {
      expect(SentryConfig.crashEnabled, isFalse);
    });

    test('environment delegates to ApiConfig.environment', () {
      expect(SentryConfig.environment, ApiConfig.environment);
    });

    test('release contains build name and number', () {
      final release = SentryConfig.release;
      expect(release, contains('deliverpuyo_mobile@'));
      expect(release, contains('+'));
    });

    test('release never contains DSN or tokens', () {
      final release = SentryConfig.release;
      expect(release, isNot(contains('sentry')));
      expect(release, isNot(contains('http')));
    });
  });
}
