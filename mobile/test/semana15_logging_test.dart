import 'dart:convert';
import 'package:deliverpuyo_mobile/config/api_config.dart';
import 'package:deliverpuyo_mobile/services/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'structured logger only emits fixed vocabulary and obeys environment',
    () {
      final lines = <String>[];
      final logger = AppLogger(sink: lines.add);
      for (final level in LogLevel.values) {
        logger.record(
          level: level,
          module: LogModule.orders,
          action: LogAction.validate,
          errorType: LogErrorType.invalidDraft,
        );
      }
      if (!ApiConfig.loggingEnabled) {
        expect(lines, isEmpty);
      } else {
        expect(lines.length, 4);
        for (var i = 0; i < lines.length; i++) {
          expect(jsonDecode(lines[i]), {
            'level': LogLevel.values[i].name,
            'module': 'orders',
            'action': 'validate',
            'errorType': 'invalidDraft',
          });
        }
      }
    },
  );
  test('disabled structured logging emits nothing', () {
    final lines = <String>[];
    AppLogger(sink: lines.add, enabled: false).record(
      level: LogLevel.debug,
      module: LogModule.orders,
      action: LogAction.validate,
    );
    expect(lines, isEmpty);
  });
}
