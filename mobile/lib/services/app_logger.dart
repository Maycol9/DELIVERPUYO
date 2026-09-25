import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

enum LogLevel { debug, info, warning, error }

enum LogModule { orders }

enum LogAction { validate }

enum LogErrorType { invalidDraft }

/// Closed vocabulary: callers cannot supply payloads, identifiers or error text.
class AppLogger {
  AppLogger({void Function(String)? sink, bool? enabled})
    : _sink = sink ?? debugPrint,
      _enabled = (enabled ?? true) && ApiConfig.loggingEnabled;
  final void Function(String) _sink;
  final bool _enabled;

  void record({
    required LogLevel level,
    required LogModule module,
    required LogAction action,
    LogErrorType? errorType,
  }) {
    if (!_enabled) return;
    _sink(
      jsonEncode({
        'level': level.name,
        'module': module.name,
        'action': action.name,
        if (errorType != null) 'errorType': errorType.name,
      }),
    );
  }
}
