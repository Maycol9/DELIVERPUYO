import 'package:deliverpuyo_mobile/models/order.dart';
import 'package:deliverpuyo_mobile/models/order_evidence.dart';
import 'package:deliverpuyo_mobile/orders/order_repository.dart';
import 'package:deliverpuyo_mobile/services/api_exception.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'semana13_test.dart' show makeClient, jsonBody;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  const draft = OrderDraft(
    addressId: 'test-address',
    productId: 'test-product',
    quantity: '3',
    photo: OrderPhoto(path: 'synthetic.jpg', capturedAt: '2026-09-22'),
    location: OrderLocation(
      latitude: 0,
      longitude: 0,
      accuracy: 100,
      capturedAt: '2026-09-22',
      approximate: true,
    ),
  );
  for (final failure in [
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
  ]) {
    test(
      '$failure before POST persists full draft and retries once after recreation',
      () async {
        var offline = true;
        var posts = 0;
        final client = makeClient((request) async {
          if (offline) {
            throw DioException(requestOptions: request, type: failure);
          }
          if (request.method == 'POST') {
            posts++;
            expect(request.data, draft.toCreateJson());
            return jsonBody(201, {
              'data': {
                'id': 'created',
                'status': 'PENDING',
                'total': 6,
                'createdAt': '2026-09-22',
              },
            });
          }
          return jsonBody(200);
        });
        addTearDown(() => client.dio.close(force: true));
        final api = ApiService(client: client);
        final local = OrderLocalDataSource();
        await expectLater(
          OrderRepository(api, local).create('u', '', draft),
          throwsA(isA<ApiException>()),
        );
        expect(posts, 0);
        expect(await local.read('u'), {
          ...draft.toLocalJson(),
          'status': 'pending',
        });
        offline = false;
        final recreated = OrderRepository(api, OrderLocalDataSource());
        await recreated.synchronize('u', '');
        await recreated.synchronize('u', '');
        expect(posts, 1);
        expect(await local.read('u'), isNull);
      },
    );
  }
  test('POST timeout retains sending data and never blindly replays', () async {
    var posts = 0;
    final client = makeClient((request) async {
      if (request.method == 'POST') {
        posts++;
        throw DioException(
          requestOptions: request,
          type: DioExceptionType.receiveTimeout,
        );
      }
      return jsonBody(200);
    });
    addTearDown(() => client.dio.close(force: true));
    final local = OrderLocalDataSource();
    final api = ApiService(client: client);
    await expectLater(
      OrderRepository(api, local).create('u', '', draft),
      throwsA(isA<ApiException>()),
    );
    expect(await local.read('u'), {
      ...draft.toLocalJson(),
      'status': 'sending',
    });
    await OrderRepository(api, local).synchronize('u', '');
    expect(posts, 1);
    expect(await local.read('u'), isNotNull);
  });
}
