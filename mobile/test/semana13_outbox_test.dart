import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:deliverpuyo_mobile/orders/order_repository.dart';
import 'package:deliverpuyo_mobile/models/order.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:deliverpuyo_mobile/services/api_exception.dart';

class OrderApi extends ApiService {
  bool offline = false;
  int? failure;
  int posts = 0;
  @override
  Future<List<OrderSummary>> getOrders(String token) async {
    if (offline) throw const ApiException(message: 'Sin conexión');
    return [];
  }

  @override
  Future<OrderSummary> createOrder({
    required String token,
    required OrderDraft draft,
  }) async {
    posts++;
    if (failure != null) throw ApiException.fromStatus(failure!);
    return const OrderSummary(
      id: 'created',
      status: 'PENDING',
      total: 3,
      createdAt: '2026-09-11',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  const draft = OrderDraft(addressId: 'a', productId: 'p', quantity: '1');
  test('offline preflight queues without POST; reconnect sends once', () async {
    final api = OrderApi()..offline = true;
    final local = OrderLocalDataSource();
    final repository = OrderRepository(api, local);
    await expectLater(
      repository.create('user', '', draft),
      throwsA(isA<ApiException>()),
    );
    expect(api.posts, 0);
    expect((await local.read('user'))!['status'], 'pending');
    api.offline = false;
    await repository.synchronize('user', '');
    await repository.synchronize('user', '');
    expect(api.posts, 1);
    expect(await local.read('user'), isNull);
  });
  test(
    'ambiguous POST never replays on reconnect or button resubmit',
    () async {
      final api = OrderApi()..failure = 503;
      final local = OrderLocalDataSource();
      final repository = OrderRepository(api, local);
      await expectLater(
        repository.create('user', '', draft),
        throwsA(isA<ApiException>()),
      );
      expect((await local.read('user'))!['status'], 'sending');
      await repository.synchronize('user', '');
      await expectLater(
        repository.create('user', '', draft),
        throwsA(isA<ApiException>()),
      );
      expect(api.posts, 1);
    },
  );
  test(
    '422 removes outbox marker so corrected draft can be submitted',
    () async {
      final api = OrderApi()..failure = 422;
      final local = OrderLocalDataSource();
      final repository = OrderRepository(api, local);
      await expectLater(
        repository.create('user', '', draft),
        throwsA(isA<ApiException>()),
      );
      expect(await local.read('user'), isNull);
      api.failure = null;
      await repository.create('user', '', draft);
      expect(api.posts, 2);
    },
  );
  test('pending queue persists across repository recreation', () async {
    final api = OrderApi()..offline = true;
    await expectLater(
      OrderRepository(api, OrderLocalDataSource()).create('user', '', draft),
      throwsA(isA<ApiException>()),
    );
    api.offline = false;
    await OrderRepository(api, OrderLocalDataSource()).synchronize('user', '');
    expect(api.posts, 1);
  });
  test('queue isolated by account', () async {
    final local = OrderLocalDataSource();
    await local.write('alice', draft, 'pending');
    final api = OrderApi();
    await OrderRepository(api, local).synchronize('bob', '');
    expect(api.posts, 0);
    expect(await local.read('alice'), isNotNull);
  });
}
