import 'package:flutter/foundation.dart';
import 'api_config.dart';

/// Configuration constants for Sentry, all read from `--dart-define`.
///
/// No DSN, token, or secret is ever hardcoded in source.
/// The DSN must be supplied at build/run time:
///
/// ```
/// flutter run --dart-define=SENTRY_DSN=<real-dsn>
/// ```
class SentryConfig {
  const SentryConfig._();

  /// DSN read from `--dart-define=SENTRY_DSN`.
  /// Empty string when not provided.
  static const String dsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Test mode flag read from `--dart-define=SENTRY_TEST_MODE`.
  /// Defaults to `false`.
  static const bool testMode = bool.fromEnvironment(
    'SENTRY_TEST_MODE',
    defaultValue: false,
  );

  /// Sentry is considered enabled when a DSN is provided.
  static bool get isEnabled => dsn.isNotEmpty;

  static bool allowsTestAction({
    required bool debug,
    required String environment,
    required bool testMode,
  }) => debug && environment == 'dev' && testMode;

  static bool get crashEnabled => allowsTestAction(
    debug: kDebugMode,
    environment: environment,
    testMode: testMode,
  );

  /// Re-uses the existing `ApiConfig.environment` (dart-define AMBIENTE).
  static String get environment => ApiConfig.environment;

  /// Build name from Flutter's build configuration (e.g. `1.0.0`).
  static const String _buildName = String.fromEnvironment(
    'FLUTTER_BUILD_NAME',
    defaultValue: '0.0.0',
  );

  /// Build number from Flutter's build configuration (e.g. `1`).
  static const String _buildNumber = String.fromEnvironment(
    'FLUTTER_BUILD_NUMBER',
    defaultValue: '0',
  );

  /// Release identifier: `deliverpuyo_mobile@<buildName>+<buildNumber>`.
  static String get release => 'deliverpuyo_mobile@$_buildName+$_buildNumber';
}
