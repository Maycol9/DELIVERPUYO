import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:deliverpuyo_mobile/auth/auth_controller.dart';
import 'package:deliverpuyo_mobile/config/sentry_config.dart';
import 'package:deliverpuyo_mobile/providers/app_providers.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:deliverpuyo_mobile/services/sentry_service.dart';
import 'package:deliverpuyo_mobile/services/sentry_privacy.dart';
import 'package:deliverpuyo_mobile/services/sentry_dio_interceptor.dart';
import 'package:deliverpuyo_mobile/models/auth_session.dart';
import 'semana13_test.dart'
    show MemorySession, makeClient, jsonBody, session, protected;

class MemoryTransport implements Transport {
  final envelopes = <SentryEnvelope>[];
  @override
  Future<SentryId?> send(SentryEnvelope envelope) async {
    envelopes.add(envelope);
    return SentryId.empty();
  }
}

class DelayedSession extends MemorySession {
  final pending = Completer<AuthSession?>();
  @override
  Future<AuthSession?> read() => pending.future;
}

Future<Scope> currentScope() async {
  late Scope result;
  await Sentry.configureScope((scope) {
    result = scope;
  });
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    await Sentry.init((options) {
      options.dsn = 'https://public@example.invalid/1';
      options.transport = MemoryTransport();
      options.beforeSend = SentryPrivacy.beforeSend;
      options.sendDefaultPii = false;
    });
    SentryService.clearUser();
  });
  tearDown(() async {
    SentryService.clearUser();
    await Sentry.close();
  });

  test('real ApiClient connects safe response and error breadcrumbs', () async {
    final client = makeClient((request) async {
      if (request.path.contains('failure')) {
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
          error: 'password secret, address private, -1.2345,-78.1234',
        );
      }
      return jsonBody(200, {
        'email': 'private@example.invalid',
        'token': 'secret',
      });
    });
    addTearDown(() => client.dio.close(force: true));
    expect(
      client.dio.interceptors.whereType<SentryDioBreadcrumbInterceptor>(),
      hasLength(1),
    );
    await client.dio.post(
      '/api/orders/private-address?token=secret',
      data: {'password': 'secret'},
      options: Options(headers: {'X-Private': 'secret'}),
    );
    await expectLater(
      client.dio.get('/failure?email=private@example.invalid'),
      throwsA(isA<DioException>()),
    );
    final crumbs = (await currentScope()).breadcrumbs;
    if (!SentryConfig.isEnabled) {
      expect(crumbs, isEmpty);
      return;
    }
    expect(crumbs, hasLength(2));
    expect(crumbs.first.message, '/api/orders');
    expect(crumbs.first.data, {'method': 'POST', 'status': '200'});
    expect(crumbs.last.message, '[ruta]');
    expect(crumbs.last.data, {
      'method': 'GET',
      'error_type': 'connectionError',
    });
    expect(
      jsonEncode(crumbs.map((c) => c.toJson()).toList()),
      isNot(contains('secret')),
    );
  });

  test(
    'restore, save, refresh and logout manage an ephemeral identity',
    () async {
      final storage = MemorySession();
      final client = makeClient(
        (request) async => request.path == '/api/auth/refresh'
            ? jsonBody(200, {
                'data': {
                  'accessToken': 'new',
                  'refreshToken': 'new-refresh',
                  'expiresInSeconds': 900,
                },
              })
            : jsonBody(
                request.headers['Authorization'] == 'Bearer new' ? 200 : 401,
              ),
        store: storage,
      );
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(ApiService(client: client)),
        ],
      );
      addTearDown(() {
        container.dispose();
        client.dio.close(force: true);
      });
      final auth = container.read(authControllerProvider.notifier);
      await auth.restore();
      final restored = (await currentScope()).user?.id;
      expect(
        restored,
        SentryConfig.isEnabled ? matches(r'^[a-f0-9]{32}$') : isNull,
      );
      await client.saveSession(session('old'));
      final saved = (await currentScope()).user?.id;
      if (SentryConfig.isEnabled) {
        expect(saved, isNot(restored));
        expect((await currentScope()).user!.toJson().keys, ['id']);
      }
      await protected(client);
      expect((await currentScope()).user?.id, saved);
      auth.logout();
      expect((await currentScope()).user, isNull);
      expect((await currentScope()).breadcrumbs, isEmpty);
      await client.saveSession(session('next'));
      if (SentryConfig.isEnabled) {
        expect((await currentScope()).user?.id, isNot(saved));
      }
      await client.clearSession();
      expect((await currentScope()).user, isNull);
    },
  );

  test('free text and full HTTP payloads never survive beforeSend', () {
    const secret =
        'unlabelled password; private@example.invalid; 1234567890; Calle privada; -1.2345,-78.1234; prefix eyJabc.def.ghi';
    final event = SentryEvent.fromJson({
      'event_id': '71223344556677889900aabbccddeeff',
      'timestamp': '2026-09-24T00:00:00.000Z',
      'message': {
        'formatted': secret,
        'message': secret,
        'params': [secret],
      },
      'request': {
        'url': 'https://example.invalid/api/orders/$secret',
        'method': 'POST',
        'headers': {'X-Private': secret},
        'data': secret,
        'cookies': secret,
      },
      'exception': {
        'values': [
          {
            'type': 'StateError',
            'value': secret,
            'stacktrace': {
              'frames': [
                {
                  'filename': 'app.dart',
                  'function': 'submit',
                  'lineno': 10,
                  'vars': {'secret': secret},
                },
              ],
            },
          },
        ],
      },
    });
    final clean = SentryPrivacy.beforeSend(event, Hint());
    expect(clean, isNotNull);
    final encoded = jsonEncode(clean!.toJson());
    for (final value in [
      'unlabelled',
      'private@example.invalid',
      '1234567890',
      'Calle privada',
      '-1.2345',
      'eyJabc',
      'X-Private',
    ]) {
      expect(encoded, isNot(contains(value)));
    }
    expect(encoded, contains('submit'));
    expect(encoded, contains('StateError'));
  });

  test('route and method allowlists reject arbitrary metadata', () {
    expect(
      SentryDioBreadcrumbInterceptor.safePath('/prefix/api/orders'),
      '[ruta]',
    );
    expect(
      SentryDioBreadcrumbInterceptor.safePath('/api/orders-secret'),
      '[ruta]',
    );
    expect(SentryDioBreadcrumbInterceptor.safeMethod('SECRET'), 'OTHER');
  });

  test('a pending restore cannot restore identity after logout', () async {
    final storage = DelayedSession();
    final client = makeClient((_) async => jsonBody(200), store: storage);
    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(ApiService(client: client)),
      ],
    );
    addTearDown(() {
      container.dispose();
      client.dio.close(force: true);
    });
    final auth = container.read(authControllerProvider.notifier);
    final restoring = auth.restore();
    auth.logout();
    storage.pending.complete(session('old'));
    await restoring;
    expect(container.read(authControllerProvider).session, isNull);
    expect((await currentScope()).user, isNull);
  });

  test('failed refresh clears the Sentry user', () async {
    final client = makeClient((_) async => jsonBody(401));
    addTearDown(() => client.dio.close(force: true));
    await client.saveSession(session('old'));
    await protected(client);
    expect((await currentScope()).user, isNull);
  });
}
