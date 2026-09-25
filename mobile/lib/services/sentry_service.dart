import 'dart:math';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/sentry_config.dart';
import 'sentry_privacy.dart';

/// Entry point for Sentry integration in DeliverPuyo.
///
/// All public methods are no-ops when [SentryConfig.isEnabled] is `false`
/// (i.e. no DSN was provided via `--dart-define=SENTRY_DSN`), so the app
/// runs normally without Sentry.
class SentryService {
  const SentryService._();

  // ── Configuration ──────────────────────────────────────────────

  /// Callback passed to [SentryFlutter.init].
  /// Sets DSN, environment, release, privacy filter and disables
  /// features that could leak PII.
  static void configureOptions(SentryFlutterOptions options) {
    options
      ..dsn = SentryConfig.dsn
      ..environment = SentryConfig.environment
      ..release = SentryConfig.release
      ..sendDefaultPii = false
      ..beforeSend = SentryPrivacy.beforeSend
      // Sentry 9 has separate telemetry channels that bypass beforeSend.
      // This integration only sends sanitized error/message events.
      ..enableLogs = false
      ..enableMetrics = false
      ..beforeSendLog = ((_) => null)
      ..beforeSendMetric = ((_) => null)
      ..enableAutoPerformanceTracing = false
      ..enableUserInteractionBreadcrumbs = false
      ..enableAutoNativeBreadcrumbs = false
      ..enableAppLifecycleBreadcrumbs = false
      ..attachScreenshot = false
      ..reportSilentFlutterErrors = false
      ..anrEnabled = false
      ..maxCacheItems = 10;
  }

  /// Sets up [FlutterError.onError] to dump errors to console.
  /// Must be called **before** [SentryFlutter.init] so that the SDK's
  /// [FlutterErrorIntegration] saves this handler as the "default"
  /// and invokes it after capturing to Sentry — preserving console
  /// output without double-reporting.
  static void setupFlutterError() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
  }

  /// Initializes Sentry and runs the app.
  /// When Sentry is disabled (no DSN), runs the app normally.
  static Future<void> initApp(FutureOr<void> Function() appRunner) async {
    if (!SentryConfig.isEnabled) {
      await appRunner();
      return;
    }
    await SentryFlutter.init(
      configureOptions,
      appRunner: () async => appRunner(),
    );
  }

  // ── User ────────────────────────────────────────────────────────

  static String? _anonymousId;

  /// Ephemeral random ID, never derived from account identifiers or PII.
  static void setAnonymousUser() {
    if (!SentryConfig.isEnabled) return;
    try {
      final random = Random.secure();
      _anonymousId ??= List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      Sentry.configureScope((scope) {
        scope.setUser(SentryUser(id: _anonymousId));
      });
    } catch (_) {
      // Telemetry must not prevent authentication.
    }
  }

  /// Clears the current user context.
  static void clearUser() {
    _anonymousId = null;
    if (!SentryConfig.isEnabled) return;
    Sentry.configureScope((scope) {
      scope.setUser(null);
      scope.clearBreadcrumbs();
    });
  }

  // ── Breadcrumbs ─────────────────────────────────────────────────

  /// Adds a safe breadcrumb to Sentry.
  ///
  /// Only the [message], [category] and [level] are recorded.
  /// Callers must ensure [message] does not contain PII.
  static void addBreadcrumb({
    required String message,
    String category = 'deliverpuyo',
    SentryLevel level = SentryLevel.info,
  }) {
    if (!SentryConfig.isEnabled) return;
    Sentry.addBreadcrumb(
      Breadcrumb(message: message, category: category, level: level),
    );
  }

  // ── Logging integration ─────────────────────────────────────────

  /// Captures a warning-level message in Sentry.
  /// Intended for integration with [AppLogger] when level == warning.
  /// The [message] is a structured string from the closed vocabulary
  /// of [AppLogger] and does not contain PII.
  static Future<void> captureWarning(String message) async {
    if (!SentryConfig.isEnabled) return;
    await Sentry.captureMessage(message, level: SentryLevel.warning);
  }

  /// Captures an exception in Sentry with its stack trace.
  static Future<void> captureError(
    dynamic exception,
    StackTrace? stackTrace,
  ) async {
    if (!SentryConfig.isEnabled) return;
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }

  // ── Test crash ─────────────────────────────────────────────────

  /// Manual debug probe. Explicit capture keeps the app available for inspection.
  /// Returning an ID does not prove remote reception.
  static Future<SentryId?> triggerTestCrash() async {
    if (!SentryConfig.crashEnabled || !SentryConfig.isEnabled) return null;
    return Sentry.captureException(
      StateError('DeliverPuyo manual Sentry test'),
      stackTrace: StackTrace.current,
      withScope: (scope) {
        scope.setTag('sentry_test', 'manual');
      },
    );
  }
}
