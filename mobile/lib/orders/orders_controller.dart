import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import '../models/order.dart';
import '../providers/app_providers.dart';
import '../services/api_exception.dart';
import '../state/remote_state.dart';

final ordersControllerProvider =
    NotifierProvider<OrdersController, RemoteState<List<OrderSummary>>>(
      OrdersController.new,
    );

class OrdersController extends Notifier<RemoteState<List<OrderSummary>>> {
  @override
  RemoteState<List<OrderSummary>> build() => const RemoteInitial();

  Future<void> load() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = const RemoteError('Inicia sesión para ver tus pedidos.');
      return;
    }

    state = const RemoteLoading();
    try {
      final orders = await ref
          .read(apiServiceProvider)
          .getOrders(session.accessToken);
      state = orders.isEmpty
          ? const RemoteEmpty('Todavía no tienes pedidos.')
          : RemoteData(orders);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        ref.read(authControllerProvider.notifier).handleUnauthorized();
      }
      state = RemoteError(error.message, statusCode: error.statusCode);
    }
  }

  Future<CreateOrderResult> create(OrderDraft draft) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      return const CreateOrderResult.failure(
        message: 'Inicia sesión para crear un pedido.',
      );
    }
    try {
      final order = await ref
          .read(apiServiceProvider)
          .createOrder(token: session.accessToken, draft: draft);
      ref.read(orderDraftProvider.notifier).clear();
      await load();
      return CreateOrderResult.success(order);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        ref.read(authControllerProvider.notifier).handleUnauthorized();
      }
      return CreateOrderResult.failure(
        message: error.message,
        statusCode: error.statusCode,
        fieldErrors: error.fieldErrors,
      );
    }
  }
}

class CreateOrderResult {
  const CreateOrderResult._({
    required this.success,
    required this.message,
    this.order,
    this.statusCode,
    this.fieldErrors = const {},
  });

  final bool success;
  final String message;
  final OrderSummary? order;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  const CreateOrderResult.success(OrderSummary order)
    : this._(
        success: true,
        order: order,
        message: 'Pedido creado correctamente.',
      );

  const CreateOrderResult.failure({
    required String message,
    int? statusCode,
    Map<String, String> fieldErrors = const {},
  }) : this._(
         success: false,
         message: message,
         statusCode: statusCode,
         fieldErrors: fieldErrors,
       );
}

final authNoticeProvider = Provider<String?>((ref) {
  final state = ref.watch(authControllerProvider);
  return switch (state) {
    Unauthenticated(:final message) => message,
    AuthFailure(:final message) => message,
    Authenticated(:final notice) => notice,
    _ => null,
  };
});
