import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:deliverpuyo_mobile/services/sentry_privacy.dart';

void main() {
  const eventId = '71223344556677889900aabbccddeeff';
  const timestamp = '2024-01-01T00:00:00.000Z';

  group('SentryPrivacy sanitization', () {
    test('Authorization header is redacted', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'request': {
          'url': 'https://api.deliverpuyo.com/api/orders',
          'method': 'GET',
          'headers': {
            'Authorization': 'Bearer secret-jwt-token',
            'Content-Type': 'application/json',
          },
        },
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final json = result!.toJson();
      final request = json['request'] as Map<String, dynamic>;
      expect(request['headers'], isNull);
    });

    test('accessToken is redacted', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {'accessToken': 'abc123secret', 'safeKey': 'value'},
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      expect(extra['accessToken'], SentryPrivacy.redacted);
      expect(extra['safeKey'], 'value');
    });

    test('refreshToken is redacted', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {'refreshToken': 'refresh-xyz-789'},
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      expect(extra['refreshToken'], SentryPrivacy.redacted);
    });

    test('password is redacted', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {'password': 'superSecret123'},
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      expect(extra['password'], SentryPrivacy.redacted);
    });

    test('email is redacted', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {'email': 'user@example.com'},
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      expect(extra['email'], SentryPrivacy.redacted);
    });

    test('latitude/longitude are redacted', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {'latitude': '-0.93', 'longitude': '-78.94', 'safe': 'ok'},
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      expect(extra['latitude'], SentryPrivacy.redacted);
      expect(extra['longitude'], SentryPrivacy.redacted);
      expect(extra['safe'], 'ok');
    });

    test('HTTP method and status are preserved when safe', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'request': {
          'url': 'https://api.deliverpuyo.com/api/products',
          'method': 'POST',
          'headers': {'Content-Type': 'application/json'},
        },
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final request = result!.toJson()['request'] as Map<String, dynamic>;
      expect(request['method'], 'POST');
      expect(request['url'], '/api/products');
      expect(request['headers'], isNull);
    });

    test('User email and name are removed', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'user': {
          'id': 'user-1',
          'email': 'test@example.com',
          'name': 'Test User',
          'username': 'testuser',
        },
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final user = result!.toJson()['user'] as Map<String, dynamic>;
      expect(user['email'], isNull);
      expect(user['name'], isNull);
      expect(user['username'], isNull);
      expect(user['id'], 'user-1');
    });

    test('Bearer token in string value is redacted', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {
          'someKey': 'Bearer eyJhbGci.token.data',
          'safeKey': 'safe-value',
        },
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      expect(extra['someKey'], SentryPrivacy.redacted);
      expect(extra['safeKey'], 'safe-value');
    });

    test('JWT token in string value is redacted', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {'token': 'eyJhbGci.eyJzdWI.signature', 'safe': 'plain-text'},
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      expect(extra['token'], SentryPrivacy.redacted);
      expect(extra['safe'], 'plain-text');
    });

    test('Nested maps are recursively sanitized', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {
          'level1': {
            'password': 'nested-secret',
            'safe': 'safe-nested',
            'level2': {'accessToken': 'nested-token'},
          },
        },
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      final level1 = extra['level1'] as Map<String, dynamic>;
      expect(level1['password'], SentryPrivacy.redacted);
      expect(level1['safe'], 'safe-nested');
      final level2 = level1['level2'] as Map<String, dynamic>;
      expect(level2['accessToken'], SentryPrivacy.redacted);
    });

    test('Lists are recursively sanitized', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {
          'items': [
            {'email': 'a@b.com'},
            {'safe': 'value'},
          ],
        },
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      final items = extra['items'] as List;
      expect(items[0], {'email': SentryPrivacy.redacted});
      expect(items[1], {'safe': 'value'});
    });

    test('Sensitive keys are matched case-insensitively', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {
          'ACCESS_TOKEN': 'token1',
          'AccessToken': 'token2',
          'accesstoken': 'token3',
          'Refresh_Token': 'token4',
        },
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      expect(extra['ACCESS_TOKEN'], SentryPrivacy.redacted);
      expect(extra['AccessToken'], SentryPrivacy.redacted);
      expect(extra['accesstoken'], SentryPrivacy.redacted);
      expect(extra['Refresh_Token'], SentryPrivacy.redacted);
    });

    test('Email in string value is redacted', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'extra': {'user': 'contact@example.com', 'safe': 'not-an-email'},
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final extra = result!.toJson()['extra'] as Map<String, dynamic>;
      expect(extra['user'], SentryPrivacy.redacted);
      expect(extra['safe'], 'not-an-email');
    });

    test('Breadcrumbs are sanitized', () {
      final event = SentryEvent.fromJson({
        'event_id': eventId,
        'timestamp': timestamp,
        'breadcrumbs': [
          {
            'timestamp': timestamp,
            'message': 'Login attempt',
            'data': {'accessToken': 'crumb-token'},
            'category': 'auth',
            'level': 'info',
            'type': 'default',
          },
        ],
      });
      final result = SentryPrivacy.beforeSend(event, Hint());
      expect(result, isNotNull);
      final breadcrumbs = result!.toJson()['breadcrumbs'] as List<dynamic>;
      final crumb = breadcrumbs[0] as Map<String, dynamic>;
      expect(crumb['data'], isNull);
      expect(crumb['message'], SentryPrivacy.redacted);
    });
  });
}
