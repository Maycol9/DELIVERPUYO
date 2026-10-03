import 'package:deliverpuyo_mobile/services/sentry_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  test(
    'Sentry 9 options retain event filter and disable additional capture',
    () {
      final options = SentryFlutterOptions();
      SentryService.configureOptions(options);
      expect(options.sendDefaultPii, isFalse);
      expect(options.beforeSend, isNotNull);
      expect(options.enableAutoPerformanceTracing, isFalse);
      expect(options.enableUserInteractionBreadcrumbs, isFalse);
      expect(options.enableAutoNativeBreadcrumbs, isFalse);
      expect(options.enableAppLifecycleBreadcrumbs, isFalse);
      expect(options.attachScreenshot, isFalse);
      // Verify the SDK default without enabling its experimental capture API.
      // ignore: experimental_member_use
      expect(options.attachViewHierarchy, isFalse);
      expect(options.replay.sessionSampleRate ?? 0, 0);
      expect(options.replay.onErrorSampleRate ?? 0, 0);
    },
  );

  test(
    'new log and metric channels cannot bypass the event privacy filter',
    () async {
      final options = SentryFlutterOptions();
      SentryService.configureOptions(options);
      expect(options.enableLogs, isFalse);
      expect(options.enableMetrics, isFalse);
      final now = DateTime.utc(2026, 9, 22);
      expect(
        await options.beforeSendLog!(
          SentryLog(
            timestamp: now,
            level: SentryLogLevel.info,
            body: 'synthetic@example.invalid',
            attributes: {},
          ),
        ),
        isNull,
      );
      expect(
        await options.beforeSendMetric!(
          SentryCounterMetric(
            timestamp: now,
            name: 'synthetic@example.invalid',
            value: 1,
            traceId: SentryId.empty(),
          ),
        ),
        isNull,
      );
    },
  );

  test(
    'configured hook removes address and coordinates while retaining release and stack',
    () async {
      final options = SentryFlutterOptions();
      SentryService.configureOptions(options);
      final event = SentryEvent.fromJson({
        'event_id': '71223344556677889900aabbccddeeff',
        'timestamp': '2026-09-22T00:00:00.000Z',
        'release': 'deliverpuyo_mobile@1.0.0+1',
        'extra': {
          'address': 'synthetic destination',
          'coordinates': [1.23, 4.56],
        },
        'exception': {
          'values': [
            {
              'type': 'StateError',
              'value': 'Synthetic test',
              'stacktrace': {
                'frames': [
                  {'filename': 'app.dart', 'function': 'submit', 'lineno': 10},
                ],
              },
            },
          ],
        },
      });
      final result = await options.beforeSend!(event, Hint());
      expect(result, isNotNull);
      final json = result!.toJson();
      expect(json['release'], 'deliverpuyo_mobile@1.0.0+1');
      expect(json['extra'], {
        'address': '[REDACTED]',
        'coordinates': '[REDACTED]',
      });
      final exception = (json['exception'] as Map)['values'] as List;
      final frames = (exception.single['stacktrace'] as Map)['frames'] as List;
      expect(frames.single['function'], 'submit');
    },
  );
}
