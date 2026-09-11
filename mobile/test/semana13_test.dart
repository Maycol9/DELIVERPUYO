import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliverpuyo_mobile/config/api_config.dart';
import 'package:deliverpuyo_mobile/models/app_user.dart';
import 'package:deliverpuyo_mobile/models/auth_session.dart';
import 'package:deliverpuyo_mobile/models/product.dart';
import 'package:deliverpuyo_mobile/models/order.dart';
import 'package:deliverpuyo_mobile/services/api_client.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:deliverpuyo_mobile/services/api_exception.dart';
import 'package:deliverpuyo_mobile/services/api_error_translator.dart';
import 'package:deliverpuyo_mobile/storage/session_storage.dart';
import 'package:deliverpuyo_mobile/products/product_repository.dart';

class MemorySession implements SessionStorage {
  AuthSession? value = session('old');
  @override
  Future<AuthSession?> read() async => value;
  @override
  Future<void> write(AuthSession s) async {
    value = s;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

AuthSession session(String access) => AuthSession(
  user: const AppUser(
    id: 'u',
    name: 'Test',
    email: 'test@example.invalid',
    role: 'CLIENT',
  ),
  accessToken: access,
  refreshToken: 'fake-refresh',
  expiresInSeconds: 900,
);

class Adapter implements HttpClientAdapter {
  Adapter(this.reply);
  final Future<ResponseBody> Function(RequestOptions) reply;
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? s,
    Future<void>? c,
  ) => reply(o);
  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(
  int status, [
  Object data = const {'success': true, 'data': []},
]) => ResponseBody.fromString(
  jsonEncode(data),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);
ApiClient makeClient(
  Future<ResponseBody> Function(RequestOptions) reply, {
  MemorySession? store,
  List<String>? logs,
  List<Duration> delays = const [],
}) {
  final client = ApiClient(
    storage: store ?? MemorySession(),
    logging: logs != null,
    logger: logs?.add,
    retryDelays: delays,
  );
  client.dio.httpClientAdapter = Adapter(reply);
  return client;
}

Future<Response<dynamic>> protected(ApiClient c) =>
    c.dio.get('/api/orders', options: Options(extra: {'protected': true}));
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('dev local baseUrl and configured timeouts', () {
    ApiConfig.validate(url: 'http://10.0.2.2:3000', ambiente: 'dev');
    final c = makeClient((_) async => jsonBody(200));
    expect(c.dio.options.baseUrl, ApiConfig.baseUrl);
    expect(c.dio.options.connectTimeout, const Duration(seconds: 10));
    expect(c.dio.options.receiveTimeout, const Duration(seconds: 15));
    expect(c.dio.options.validateStatus(422), isTrue);
  });
  for (final env in ['prod', 'staging', 'test']) {
    test('$env requires HTTPS', () {
      expect(
        () => ApiConfig.validate(url: 'http://10.0.2.2:3000', ambiente: env),
        throwsStateError,
      );
      ApiConfig.validate(url: 'https://example.invalid', ambiente: env);
    });
  }
  test('rejects unknown environment and nonlocal HTTP', () {
    expect(() => ApiConfig.validate(ambiente: 'production'), throwsStateError);
    expect(
      () => ApiConfig.validate(url: 'http://example.invalid'),
      throwsStateError,
    );
  });
  test('automatic secure token on protected request', () async {
    final c = makeClient((o) async {
      expect(o.headers['Authorization'], 'Bearer old');
      return jsonBody(200);
    });
    await protected(c);
  });
  test('public login does not send token', () async {
    final c = makeClient((o) async {
      expect(o.headers.containsKey('Authorization'), isFalse);
      return jsonBody(200);
    });
    await c.dio.post('/api/auth/login');
  });
  for (final concurrent in [1, 5]) {
    test(
      '401 refresh and retry: $concurrent concurrent requests, one refresh',
      () async {
        var refresh = 0;
        var retried = 0;
        final store = MemorySession();
        final c = makeClient((o) async {
          if (o.path == '/api/auth/refresh') {
            refresh++;
            expect(o.data, {'refreshToken': 'fake-refresh'});
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return jsonBody(200, {
              'data': {
                'accessToken': 'new',
                'refreshToken': 'rotated',
                'expiresInSeconds': 900,
              },
            });
          }
          if (o.headers['Authorization'] == 'Bearer old') return jsonBody(401);
          expect(o.extra['retried'], isTrue);
          retried++;
          return jsonBody(200);
        }, store: store);
        final responses = await Future.wait(
          List.generate(concurrent, (_) => protected(c)),
        );
        expect(responses.every((r) => r.statusCode == 200), isTrue);
        expect(refresh, 1);
        expect(retried, concurrent);
        expect(store.value!.refreshToken, 'rotated');
      },
    );
  }
  test('anti-loop second 401 clears session', () async {
    var refresh = 0;
    final store = MemorySession();
    final c = makeClient((o) async {
      if (o.path == '/api/auth/refresh') {
        refresh++;
        return jsonBody(200, {
          'data': {
            'accessToken': 'new',
            'refreshToken': 'rotated',
            'expiresInSeconds': 900,
          },
        });
      }
      return jsonBody(401);
    }, store: store);
    expect((await protected(c)).statusCode, 401);
    expect(refresh, 1);
    expect(store.value, isNull);
  });
  test('failed refresh clears storage and notifies auth', () async {
    final store = MemorySession();
    var notified = false;
    final c = makeClient((_) async => jsonBody(401), store: store);
    c.onSessionChanged = (s) {
      expect(s, isNull);
      notified = true;
    };
    await protected(c);
    expect(store.value, isNull);
    expect(notified, isTrue);
  });
  test('logout while refresh pending never restores old session', () async {
    final entered = Completer<void>(), release = Completer<void>();
    final store = MemorySession();
    final c = makeClient((o) async {
      if (o.path == '/api/auth/refresh') {
        entered.complete();
        await release.future;
        return jsonBody(200, {
          'data': {
            'accessToken': 'new',
            'refreshToken': 'rotated',
            'expiresInSeconds': 900,
          },
        });
      }
      return jsonBody(401);
    }, store: store);
    final response = protected(c);
    await entered.future;
    await c.clearSession();
    release.complete();
    await response;
    expect(store.value, isNull);
  });
  test('redacted logs exclude payload query and credentials', () async {
    final logs = <String>[];
    final c = makeClient((_) async => jsonBody(200), logs: logs);
    await protected(c);
    await c.dio.post(
      '/api/auth/login?password=sensitive',
      data: {'password': 'sensitive'},
    );
    expect(logs.join(), contains('Bearer [REDACTED]'));
    expect(logs.join(), isNot(contains('old')));
    expect(logs.join(), isNot(contains('sensitive')));
  });
  test('logging disabled produces no logs', () async {
    final logs = <String>[];
    final c = ApiClient(
      storage: MemorySession(),
      logging: false,
      logger: logs.add,
    );
    c.dio.httpClientAdapter = Adapter((_) async => jsonBody(200));
    await protected(c);
    expect(logs, isEmpty);
  });
  test('generated Product decimal category mapping and optional null', () {
    final p = Product.fromJson({
      'id': 'p',
      'name': 'Pan',
      'price': '2.50',
      'stock': 3,
      'category': {'id': 'c', 'name': 'Comida'},
    });
    expect(p.price, 2.5);
    expect(p.categoryName, 'Comida');
    expect(p.imageUrl, isNull);
    expect(p.description, isNull);
    expect(p.toJson()['category'], {'name': 'Comida'});
    expect(Product.fromJson(p.toJson()).categoryName, 'Comida');
  });
  test('generated Product accepts absent category', () {
    expect(
      Product.fromJson({
        'id': 'p',
        'name': 'Pan',
        'price': 2,
        'stock': 0,
      }).categoryName,
      isNull,
    );
  });
  test('generated Order preserves contract names and Decimal', () {
    final o = OrderSummary.fromJson({
      'id': 'o',
      'status': 'PENDING',
      'total': '4.00',
      'createdAt': '2026-09-11T00:00:00Z',
    });
    expect(o.total, 4);
    expect(o.toJson()['createdAt'], '2026-09-11T00:00:00Z');
    expect(OrderSummary.fromJson(o.toJson()).id, 'o');
  });
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
  ]) {
    test('domain message for $type', () {
      final m = ApiErrorTranslator.fromException(
        DioException(requestOptions: RequestOptions(), type: type),
      );
      expect(
        m,
        contains(
          type == DioExceptionType.connectionError
              ? 'Sin conexión'
              : 'tardó demasiado',
        ),
      );
    });
  }
  for (final status in [400, 403, 404, 409, 422, 500]) {
    test('HTTP $status translated without leaking server text', () async {
      final c = makeClient(
        (_) async => jsonBody(status, {
          'message': 'SQL SECRET',
          'errors': status == 422
              ? {
                  'items': ['Cantidad inválida'],
                }
              : null,
        }),
      );
      final api = ApiService(client: c);
      try {
        await api.getOrders('unused');
        fail('Expected error');
      } on ApiException catch (e) {
        expect(e.statusCode, status);
        expect(e.message, isNot(contains('SQL')));
        if (status == 422) expect(e.fieldErrors['items'], 'Cantidad inválida');
      }
    });
  }
  test('GET retries 5xx with bounded backoff', () async {
    var calls = 0;
    final c = makeClient(
      (_) async => jsonBody(++calls < 3 ? 503 : 200),
      delays: [Duration.zero, Duration.zero],
    );
    expect((await c.dio.get('/api/products')).statusCode, 200);
    expect(calls, 3);
  });
  test('GET network retries are bounded', () async {
    var calls = 0;
    final c = makeClient((o) async {
      calls++;
      throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
      );
    }, delays: [Duration.zero, Duration.zero]);
    await expectLater(c.dio.get('/api/products'), throwsA(isA<DioException>()));
    expect(calls, 3);
  });
  test('POST without idempotency never retries 503', () async {
    var calls = 0;
    final c = makeClient((_) async {
      calls++;
      return jsonBody(503);
    }, delays: [Duration.zero]);
    await c.dio.post('/api/orders');
    expect(calls, 1);
  });
  test('GET 422 never retries', () async {
    var calls = 0;
    final c = makeClient((_) async {
      calls++;
      return jsonBody(422);
    }, delays: [Duration.zero]);
    await c.dio.get('/api/products');
    expect(calls, 1);
  });
  test('intentional cancellation interrupts backoff', () async {
    final token = CancelToken();
    final c = makeClient((_) async {
      token.cancel();
      return jsonBody(503);
    }, delays: [const Duration(seconds: 4)]);
    await expectLater(
      c.dio.get('/api/products', cancelToken: token),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
  });
  test('repository returns cache then refreshes local', () async {
    final local = ProductLocalDataSource();
    await local.write([
      const Product(id: 'old', name: 'Anterior', price: 1, stock: 1),
    ]);
    final c = makeClient(
      (_) async => jsonBody(200, {
        'data': [
          {'id': 'new', 'name': 'Actual', 'price': '3', 'stock': 2},
        ],
      }),
    );
    final values = await ProductRepository(
      ProductRemoteDataSource(ApiService(client: c)),
      local,
    ).watch().toList();
    expect(values.first.products.first.id, 'old');
    expect(values.last.products.first.id, 'new');
    expect((await local.read())!.first.id, 'new');
  });
  test('repository retains cache on connection failure', () async {
    final local = ProductLocalDataSource();
    await local.write([
      const Product(id: 'p', name: 'Pan', price: 1, stock: 1),
    ]);
    final c = makeClient(
      (o) async => throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
      ),
    );
    final values = await ProductRepository(
      ProductRemoteDataSource(ApiService(client: c)),
      local,
    ).watch().toList();
    expect(values.last.products.first.id, 'p');
    expect(values.last.notice, contains('Sin conexión'));
  });
}
