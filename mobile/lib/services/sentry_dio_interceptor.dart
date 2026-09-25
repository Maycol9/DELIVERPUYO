import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../config/sentry_config.dart';

/// Closed-vocabulary HTTP metadata; no headers, payloads or exception text.
class SentryDioBreadcrumbInterceptor extends Interceptor {
  static const _paths = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/api/products',
    '/api/orders',
    '/api/addresses',
    '/api/categories',
  ];
  static const _methods = [
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'HEAD',
    'OPTIONS',
  ];

  static String safePath(String raw) {
    final path = Uri.tryParse(raw)?.path;
    return _paths.firstWhere(
      (p) => path == p || (path?.startsWith('$p/') ?? false),
      orElse: () => '[ruta]',
    );
  }

  static String safeMethod(String method) =>
      _methods.contains(method) ? method : 'OTHER';

  void _record(RequestOptions request, int? status, DioExceptionType? error) {
    if (!SentryConfig.isEnabled) return;
    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: safePath(request.path),
          category: 'http',
          level: error != null || (status ?? 0) >= 500
              ? SentryLevel.error
              : (status ?? 0) >= 400
              ? SentryLevel.warning
              : SentryLevel.info,
          data: {
            'method': safeMethod(request.method),
            if (status != null && status >= 100 && status <= 599)
              'status': '$status',
            if (error != null) 'error_type': error.name,
          },
        ),
      );
    } catch (_) {
      // Observability must never interrupt the transport.
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _record(response.requestOptions, response.statusCode, null);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _record(err.requestOptions, err.response?.statusCode, err.type);
    handler.next(err);
  }
}
