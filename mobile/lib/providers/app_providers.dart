import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final orderDraftProvider = NotifierProvider<OrderDraftController, OrderDraft>(
  OrderDraftController.new,
);

class OrderDraftController extends Notifier<OrderDraft> {
  @override
  OrderDraft build() => const OrderDraft();

  void setAddress(String value) {
    state = state.copyWith(addressId: value);
  }

  void setProduct(String value) {
    state = state.copyWith(productId: value);
  }

  void setQuantity(String value) {
    state = state.copyWith(quantity: value);
  }

  void clear() {
    state = const OrderDraft();
  }
}
