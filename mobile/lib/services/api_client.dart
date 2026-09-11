import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/auth_session.dart';
import '../storage/session_storage.dart';

/// One transport, including refresh. Internal flags never go over the wire.
class ApiClient {
  ApiClient({
    Dio? dio,
    SessionStorage? storage,
    bool? logging,
    void Function(String)? logger,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  }) : dio = dio ?? Dio(),
       storage = storage ?? const SecureSessionStorage(),
       logging = logging ?? ApiConfig.loggingEnabled,
       logger = logger ?? debugPrint {
    ApiConfig.validate();
    this.dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      followRedirects: false,
      validateStatus: (s) => s != null && s >= 200 && s < 600,
      headers: {'Accept': 'application/json'},
    );
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          try {
            if (o.uri.origin != Uri.parse(this.dio.options.baseUrl).origin) {
              throw StateError('Origen de API no permitido');
            }
            o.extra['started'] = DateTime.now();
            o.headers.remove('Authorization');
            if (o.extra['protected'] == true) {
              final epoch = (o.extra['epoch'] as int?) ?? _epoch;
              final session = _signedOut ? null : await this.storage.read();
              if (epoch != _epoch) {
                return h.reject(
                  DioException(
                    requestOptions: o,
                    type: DioExceptionType.cancel,
                  ),
                );
              }
              if (session != null) {
                o.headers['Authorization'] = 'Bearer ${session.accessToken}';
              }
              o.extra['epoch'] = epoch;
            }
            h.next(o);
          } catch (_) {
            h.reject(
              DioException(requestOptions: o, type: DioExceptionType.unknown),
            );
          }
        },
        onResponse: (r, h) async {
          _log(r.requestOptions, r.statusCode.toString());
          final o = r.requestOptions;
          try {
            if (r.statusCode == 401 && o.extra['protected'] == true) {
              if (o.extra['retried'] == true || o.extra['epoch'] != _epoch) {
                if (o.extra['epoch'] == _epoch) await clearSession();
                return h.next(r);
              }
              final current = await this.storage.read();
              final sent = o.headers['Authorization'];
              final changed =
                  current != null && sent != 'Bearer ${current.accessToken}';
              if (changed || await _refresh()) {
                o.extra['retried'] = true;
                return h.resolve(await this.dio.fetch<dynamic>(o));
              }
            }
            if ((r.statusCode ?? 0) >= 500 && await _retry(o)) {
              return h.resolve(await this.dio.fetch<dynamic>(o));
            }
            h.next(r);
          } on DioException catch (e) {
            h.reject(e);
          } catch (_) {
            h.reject(DioException(requestOptions: o));
          }
        },
        onError: (e, h) async {
          _log(e.requestOptions, e.type.name);
          try {
            if ([
                  DioExceptionType.connectionError,
                  DioExceptionType.connectionTimeout,
                  DioExceptionType.receiveTimeout,
                ].contains(e.type) &&
                await _retry(e.requestOptions)) {
              return h.resolve(await this.dio.fetch<dynamic>(e.requestOptions));
            }
            h.next(e);
          } on DioException catch (error) {
            h.next(error);
          }
        },
      ),
    );
  }
  final Dio dio;
  final SessionStorage storage;
  final bool logging;
  final void Function(String) logger;
  final List<Duration> retryDelays;
  void Function(AuthSession?)? onSessionChanged;
  Future<bool>? _refreshing;
  int _epoch = 0;
  bool _signedOut = false;
  Future<void> _operations = Future.value();
  Future<void> _mutate(Future<void> Function() action) {
    final next = _operations.then((_) => action());
    _operations = next.catchError((Object _) {});
    return next;
  }

  Future<void> saveSession(AuthSession session) async {
    if (session.accessToken.isEmpty ||
        session.refreshToken.isEmpty ||
        session.expiresInSeconds <= 0) {
      throw StateError('La respuesta de autenticación está incompleta.');
    }
    final epoch = ++_epoch;
    _signedOut = true;
    await _mutate(() async {
      if (epoch != _epoch) return;
      await storage.write(session);
      if (epoch == _epoch) {
        _signedOut = false;
        onSessionChanged?.call(session);
      }
    });
  }

  Future<void> clearSession() async {
    _epoch++;
    _signedOut = true;
    onSessionChanged?.call(null);
    await _mutate(storage.clear);
  }

  Future<bool> _refresh() async {
    if (_refreshing != null) return _refreshing!;
    final future = _performRefresh();
    _refreshing = future;
    try {
      return await future;
    } finally {
      if (identical(_refreshing, future)) _refreshing = null;
    }
  }

  Future<bool> _performRefresh() async {
    final epoch = _epoch;
    try {
      final old = await storage.read();
      if (old == null || old.refreshToken.isEmpty) {
        throw StateError('Sin sesión');
      }
      final r = await dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refreshToken': old.refreshToken},
      );
      if (r.statusCode != 200) throw StateError('Refresh rechazado');
      final d = r.data!['data'] as Map<String, dynamic>;
      final session = AuthSession(
        user: old.user,
        accessToken: d['accessToken'] as String,
        refreshToken: d['refreshToken'] as String,
        expiresInSeconds: d['expiresInSeconds'] as int,
      );
      if (session.accessToken.isEmpty || session.refreshToken.isEmpty) {
        throw StateError('Respuesta incompleta');
      }
      if (epoch != _epoch) return false;
      await _mutate(() async {
        if (epoch != _epoch) return;
        await storage.write(session);
        if (epoch == _epoch) onSessionChanged?.call(session);
      });
      return epoch == _epoch;
    } catch (_) {
      if (epoch == _epoch) await clearSession();
      return false;
    }
  }

  Future<bool> _retry(RequestOptions o) async {
    final n = (o.extra['networkRetries'] as int?) ?? 0;
    if (o.method != 'GET' ||
        n >= retryDelays.length ||
        o.cancelToken?.isCancelled == true) {
      return false;
    }
    o.extra['networkRetries'] = n + 1;
    await Future.any([
      Future<void>.delayed(retryDelays[n]),
      if (o.cancelToken != null) o.cancelToken!.whenCancel,
    ]);
    return o.cancelToken?.isCancelled != true;
  }

  void _log(RequestOptions o, String status) {
    if (!logging || !ApiConfig.loggingEnabled) return;
    final start = o.extra['started'] as DateTime?;
    final ms = start == null
        ? 0
        : DateTime.now().difference(start).inMilliseconds;
    // Fixed route allowlist: no query, payload, identifiers or exception text.
    final path =
        [
          '/api/auth/login',
          '/api/auth/register',
          '/api/auth/refresh',
          '/api/products',
          '/api/orders',
          '/api/addresses',
          '/api/categories',
        ].contains(o.path)
        ? o.path
        : '[ruta]';
    logger(
      '${o.method} $path $status ${ms}ms${o.headers.containsKey('Authorization') ? ' Authorization: Bearer [REDACTED]' : ''}',
    );
  }
}
