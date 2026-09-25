import 'package:sentry_flutter/sentry_flutter.dart';
import 'sentry_dio_interceptor.dart';

/// Privacy filter applied to every Sentry event via `beforeSend`.
///
/// The strategy is:
/// 1. Serialize the event to JSON.
/// 2. Recursively walk every map key and string value,
///    redacting sensitive fields.
/// 3. Remove PII fields (email, name, IP) from the user context.
/// 4. Re-hydrate a sanitized [SentryEvent] from JSON.
///
/// This guarantees uniform coverage of `request`, `user`, `breadcrumbs`,
/// `extra`, `tags`, `contexts`, `message`, and `exceptions`.
class SentryPrivacy {
  const SentryPrivacy._();

  static const String redacted = '[REDACTED]';

  /// Keys whose values must always be redacted (case-insensitive,
  /// with or without underscores / camelCase).
  static final Set<String> _sensitiveKeys = {
    'authorization',
    'headers',
    'access_token',
    'accesstoken',
    'refresh_token',
    'refreshtoken',
    'password',
    'email',
    'cedula',
    'cédula',
    'documento',
    'document',
    'direccion',
    'dirección',
    'address',
    'phone',
    'telefono',
    'teléfono',
    'latitude',
    'longitude',
    'coordinates',
    'coordenadas',
    'cookies',
    'cookie',
    'set-cookie',
    'ip_address',
    'ipaddress',
    'ip',
    'session',
    'session_id',
    'sessionid',
    'user_id',
    'userid',
    'body',
    'requestbody',
    'responsebody',
    'payload',
    'lat',
    'lng',
    'lon',
    'token',
    'secret',
    'contraseña',
    'contrasena',
  };

  /// PII keys that must be **deleted** (not redacted) from the
  /// user context to ensure no trace is sent to Sentry.
  static final Set<String> _userPiiKeys = {
    'email',
    'name',
    'username',
    'ip_address',
    'ipaddress',
    'ip',
    'geo',
    'segment',
  };

  /// Matches `Bearer <token>` (case-insensitive) in string values.
  static final RegExp _bearerPattern = RegExp(
    r'bearer\s+\S+',
    caseSensitive: false,
  );

  /// Matches JWT-like strings starting with `eyJ`.
  static final RegExp _jwtPattern = RegExp(
    r'eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+',
  );

  /// Matches email addresses.
  static final RegExp _emailPattern = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}',
  );

  /// Returns `true` when [key] (case-insensitive) matches a
  /// sensitive name, with or without underscores.
  static bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase();
    if (_sensitiveKeys.contains(lower)) return true;
    return _sensitiveKeys.contains(lower.replaceAll('_', ''));
  }

  /// Returns `true` when [key] is a user PII field that should be
  /// deleted from the user context.
  static bool _isUserPiiKey(String key) {
    final lower = key.toLowerCase();
    if (_userPiiKeys.contains(lower)) return true;
    return _userPiiKeys.contains(lower.replaceAll('_', ''));
  }

  /// Recursively sanitizes any JSON-serializable value.
  static dynamic _sanitizeValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return _sanitizeString(value);
    if (value is Map<String, dynamic>) return _sanitizeMap(value);
    if (value is Map) return _sanitizeMap(Map<String, dynamic>.from(value));
    if (value is List) return value.map(_sanitizeValue).toList();
    return value;
  }

  /// Redacts strings that look like tokens or PII.
  static String _sanitizeString(String value) {
    if (_bearerPattern.hasMatch(value) || _jwtPattern.hasMatch(value)) {
      return redacted;
    }
    if (_emailPattern.hasMatch(value)) {
      return redacted;
    }
    return value;
  }

  /// Recursively sanitizes a map: sensitive keys -> [redacted],
  /// then each value is passed through [_sanitizeValue].
  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      if (_isSensitiveKey(entry.key)) {
        result[entry.key] = redacted;
      } else {
        result[entry.key] = _sanitizeValue(entry.value);
      }
    }
    return result;
  }

  /// Removes PII fields (email, name, IP, etc.) from the `user`
  /// sub-map in the serialized event JSON.
  static void _stripUserPii(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    if (user == null) return;
    user.removeWhere((key, _) => _isUserPiiKey(key));
  }

  /// Sentry `beforeSend` hook.
  ///
  /// Serializes the event to JSON, runs the recursive sanitizer,
  /// strips user PII, and re-hydrates a clean [SentryEvent].
  /// If anything goes wrong the event is **dropped** (returns `null`)
  /// to guarantee no sensitive data leaks.
  static SentryEvent? beforeSend(SentryEvent event, Hint hint) {
    try {
      final json = event.toJson();
      // Unlabelled secrets cannot reliably be recognized in arbitrary prose.
      if (json.containsKey('message')) {
        json['message'] = {'formatted': redacted};
      }
      final exceptions = (json['exception'] as Map?)?['values'] as List?;
      for (final exception in exceptions ?? []) {
        exception['value'] = redacted;
        final frames = (exception['stacktrace'] as Map?)?['frames'] as List?;
        for (final frame in frames ?? []) {
          for (final key in [
            'vars',
            'pre_context',
            'post_context',
            'context_line',
          ]) {
            frame.remove(key);
          }
        }
      }
      final request = json['request'] as Map?;
      if (request != null) {
        json['request'] = {
          'method': SentryDioBreadcrumbInterceptor.safeMethod(
            '${request['method']}',
          ),
          'url': SentryDioBreadcrumbInterceptor.safePath('${request['url']}'),
        };
      }
      final breadcrumbs = json['breadcrumbs'] as List?;
      for (final crumb in breadcrumbs ?? []) {
        if (crumb['category'] == 'http') {
          crumb['message'] = SentryDioBreadcrumbInterceptor.safePath(
            '${crumb['message']}',
          );
          final data = crumb['data'] as Map? ?? {};
          crumb['data'] = {
            'method': SentryDioBreadcrumbInterceptor.safeMethod(
              '${data['method']}',
            ),
            if (RegExp(r'^[1-5][0-9]{2}$').hasMatch('${data['status']}'))
              'status': '${data['status']}',
            if (const [
              'connectionTimeout',
              'sendTimeout',
              'receiveTimeout',
              'badCertificate',
              'badResponse',
              'cancel',
              'connectionError',
              'unknown',
            ].contains(data['error_type']))
              'error_type': data['error_type'],
          };
        } else {
          crumb['message'] = redacted;
          crumb.remove('data');
        }
      }
      final sanitized = _sanitizeMap(json);
      _stripUserPii(sanitized);
      return SentryEvent.fromJson(sanitized);
    } catch (_) {
      return null;
    }
  }
}
