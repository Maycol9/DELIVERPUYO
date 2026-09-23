import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/sentry_config.dart';

/// Dio interceptor that records **metadata-only** breadcrumbs in Sentry.
///
/// Unlike [SentryDioInterceptor], this interceptor NEVER captures:
/// - Authorization headers
/// - Cookies or tokens
/// - Request bodies
/// - Response bodies
/// - Full URLs (only the sanitized path is used)
///
/// Captured metadata per request:
/// - HTTP method
/// - Sanitized endpoint path (from a fixed allowlist)
/// - Status code
/// - Duration in milliseconds
/// - Error type (on failure)
class SentryDioBreadcrumbInterceptor extends Interceptor {
  static const _allowedPaths = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/api/products',
    '/api/orders',
    '/api/addresses',
    '/api/categories',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!SentryConfig.isEnabled) {
      handler.next(options);
      return;
    }
    options.extra['sentry_started'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!SentryConfig.isEnabled) {
      handler.next(response);
      return;
    }
    final started =
        response.requestOptions.extra['sentry_started'] as DateTime?;
    if (started != null) {
      final ms = DateTime.now().difference(started).inMilliseconds;
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: _safePath(response.requestOptions.path),
          category: 'http',
          level: _levelFromStatus(response.statusCode),
          data: {
            'method': response.requestOptions.method,
            'status': response.statusCode?.toString() ?? 'unknown',
            'duration_ms': ms.toString(),
          },
        ),
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!SentryConfig.isEnabled) {
      handler.next(err);
      return;
    }
    final started = err.requestOptions.extra['sentry_started'] as DateTime?;
    if (started != null) {
      final ms = DateTime.now().difference(started).inMilliseconds;
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: _safePath(err.requestOptions.path),
          category: 'http',
          level: SentryLevel.error,
          data: {
            'method': err.requestOptions.method,
            'error_type': err.type.name,
            'duration_ms': ms.toString(),
          },
        ),
      );
    }
    handler.next(err);
  }

  static String _safePath(String path) {
    final match = _allowedPaths.firstWhere(
      (p) => path.contains(p),
      orElse: () => '[ruta]',
    );
    return match;
  }

  static SentryLevel _levelFromStatus(int? status) {
    if (status == null) return SentryLevel.error;
    if (status >= 500) return SentryLevel.error;
    if (status >= 400) return SentryLevel.warning;
    return SentryLevel.info;
  }
}
