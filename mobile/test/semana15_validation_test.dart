import 'package:deliverpuyo_mobile/models/order.dart';
import 'package:deliverpuyo_mobile/orders/order_repository.dart';
import 'package:deliverpuyo_mobile/services/api_exception.dart';
import 'package:deliverpuyo_mobile/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingOrderApi extends ApiService {
  int reads = 0;
  final sent = <OrderDraft>[];
  @override
  Future<List<OrderSummary>> getOrders(String token) async {
    reads++;
    return [];
  }

  @override
  Future<OrderSummary> createOrder({
    required String token,
    required OrderDraft draft,
  }) async {
    sent.add(draft);
    return const OrderSummary(
      id: 'order-test',
      status: 'PENDING',
      total: 2,
      createdAt: '2026-09-22',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  const valid = OrderDraft(addressId: 'a', productId: 'p', quantity: '2');
  final invalid = <String, OrderDraft>{
    'zero': valid.copyWith(quantity: '0'),
    'negative': valid.copyWith(quantity: '-1'),
    'missing quantity': valid.copyWith(quantity: ''),
    'fraction': valid.copyWith(quantity: '1.5'),
    'over limit': valid.copyWith(quantity: '51'),
    'missing address': valid.copyWith(addressId: ''),
    'missing product': valid.copyWith(productId: ''),
    'blank address': valid.copyWith(addressId: '  '),
  };
  for (final entry in invalid.entries) {
    test('rejects ${entry.key} before transport or outbox writes', () async {
      final api = RecordingOrderApi();
      final local = OrderLocalDataSource();
      await expectLater(
        OrderRepository(api, local).create('u', '', entry.value),
        throwsA(
          isA<ApiException>().having(
            (e) => e.fieldErrors,
            'field errors',
            isNotEmpty,
          ),
        ),
      );
      expect(api.reads, 0);
      expect(api.sent, isEmpty);
      expect(await local.read('u'), isNull);
    });
  }
  for (final quantity in ['1', '2', '50']) {
    test('accepts valid quantity $quantity and sends once', () async {
      final api = RecordingOrderApi();
      final local = OrderLocalDataSource();
      final result = await OrderRepository(
        api,
        local,
      ).create('u', '', valid.copyWith(quantity: quantity));
      expect(result.id, 'order-test');
      expect(api.sent.single.quantity, quantity);
      expect(await local.read('u'), isNull);
    });
  }
}
