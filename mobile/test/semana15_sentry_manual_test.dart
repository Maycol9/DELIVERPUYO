import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:deliverpuyo_mobile/config/sentry_config.dart';
import 'package:deliverpuyo_mobile/services/sentry_service.dart';
import 'package:deliverpuyo_mobile/widgets/sentry_test_button.dart';

void main() {
  test('test action requires debug, dev and explicit test mode', () {
    for (final debug in [false, true]) {
      for (final environment in ['dev', 'prod', 'staging', 'test', '']) {
        for (final mode in [false, true]) {
          expect(
            SentryConfig.allowsTestAction(
              debug: debug,
              environment: environment,
              testMode: mode,
            ),
            debug && environment == 'dev' && mode,
          );
        }
      }
    }
  });

  testWidgets('button requires manual tap and never captures on mount', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<SentryId?>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SentryTestButton(
            capture: () {
              calls++;
              return pending.future;
            },
          ),
        ),
      ),
    );
    expect(calls, 0);
    final button = find.byType(OutlinedButton);
    if (!SentryConfig.crashEnabled) {
      expect(button, findsNothing);
      return;
    }
    expect(button, findsOneWidget);
    if (!SentryConfig.isEnabled) {
      expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
      return;
    }
    await tester.tap(button);
    await tester.pump();
    expect(calls, 1);
    expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
    pending.complete(SentryId.fromId('71223344556677889900aabbccddeeff'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Comprueba su recepción'), findsOneWidget);
    expect(calls, 1);
  });

  test('configured privacy hook retains synthetic trace and release', () async {
    final options = SentryFlutterOptions();
    SentryService.configureOptions(options);
    final event = SentryEvent.fromJson({
      'event_id': '71223344556677889900aabbccddeeff',
      'timestamp': '2026-09-24T00:00:00.000Z',
      'release': options.release,
      'tags': {'sentry_test': 'manual'},
      'exception': {
        'values': [
          {
            'type': 'StateError',
            'value': 'synthetic text',
            'stacktrace': {
              'frames': [
                {
                  'filename': 'sentry_service.dart',
                  'function': 'SentryService.triggerTestCrash',
                  'lineno': 150,
                },
              ],
            },
          },
        ],
      },
    });
    final result = await options.beforeSend!(event, Hint());
    expect(result, isNotNull);
    final json = result!.toJson();
    expect(json['release'], SentryConfig.release);
    expect(json['tags'], {'sentry_test': 'manual'});
    final exception = (json['exception'] as Map)['values'][0];
    expect(exception['value'], '[REDACTED]');
    expect(
      exception['stacktrace']['frames'][0]['function'],
      'SentryService.triggerTestCrash',
    );
  });
}
