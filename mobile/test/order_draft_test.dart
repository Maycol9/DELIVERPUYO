import 'package:deliverpuyo_mobile/models/order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OrderDraft serializes using the real backend contract', () {
    const draft = OrderDraft(
      addressId: '550e8400-e29b-41d4-a716-446655440000',
      productId: '550e8400-e29b-41d4-a716-446655440001',
      quantity: '2',
    );

    expect(draft.toCreateJson(), {
      'addressId': '550e8400-e29b-41d4-a716-446655440000',
      'items': [
        {'productId': '550e8400-e29b-41d4-a716-446655440001', 'quantity': 2},
      ],
    });
  });
}
