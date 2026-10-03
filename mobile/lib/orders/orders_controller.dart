import 'order_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import '../models/order.dart';
import '../providers/app_providers.dart';
import '../services/api_exception.dart';
import '../state/remote_state.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(
    ref.watch(apiServiceProvider),
    OrderLocalDataSource(),
    evidence: ref.watch(evidenceStoreProvider),
    isCurrentUser: (user) =>
        ref.read(authControllerProvider).session?.user.id == user,
  ),
);

final outboxStatusProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authControllerProvider).session?.user.id;
  if (user == null) return null;
  return (await ref.read(orderRepositoryProvider).local.read(user))?['status']
      as String?;
});

final ordersControllerProvider =
    NotifierProvider<OrdersController, RemoteState<List<OrderSummary>>>(
      OrdersController.new,
    );

class OrdersController extends Notifier<RemoteState<List<OrderSummary>>> {
  @override
  RemoteState<List<OrderSummary>> build() {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.session?.user.id != next.session?.user.id) {
        state = const RemoteInitial();
      }
    });
    return const RemoteInitial();
  }

  Future<void> load() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = const RemoteError('Inicia sesión para ver tus pedidos.');
      return;
    }

    state = const RemoteLoading();
    try {
      await ref
          .read(orderRepositoryProvider)
          .synchronize(session.user.id, session.accessToken);
      final orders = await ref
          .read(apiServiceProvider)
          .getOrders(session.accessToken);
      ref.invalidate(outboxStatusProvider);
      if (ref.read(authControllerProvider).session?.user.id !=
          session.user.id) {
        return;
      }
      state = orders.isEmpty
          ? const RemoteEmpty('Todavía no tienes pedidos.')
          : RemoteData(orders);
    } on ApiException catch (error) {
      ref.invalidate(outboxStatusProvider);
      if (error.isUnauthorized) {
        ref.read(authControllerProvider.notifier).handleUnauthorized();
      }
      state = RemoteError(error.message, statusCode: error.statusCode);
    } catch (_) {
      state = const RemoteError(
        "No fue posible acceder a los pedidos guardados.",
      );
    }
  }

  Future<CreateOrderResult> create(
    OrderDraft draft, {
    bool probeValidationDev = false,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      return const CreateOrderResult.failure(
        message: 'Inicia sesión para crear un pedido.',
      );
    }
    try {
      final repository = ref.read(orderRepositoryProvider);
      final order = probeValidationDev
          ? await repository.probeValidationDev(
              session.user.id,
              session.accessToken,
              draft,
            )
          : await repository.create(
              session.user.id,
              session.accessToken,
              draft,
            );
      ref.invalidate(outboxStatusProvider);
      if (ref.read(authControllerProvider).session?.user.id !=
          session.user.id) {
        return const CreateOrderResult.failure(message: "La sesión cambió.");
      }
      ref.read(orderDraftProvider.notifier).clear();
      await load();
      return CreateOrderResult.success(order);
    } on ApiException catch (error) {
      ref.invalidate(outboxStatusProvider);
      if (error.isUnauthorized) {
        ref.read(authControllerProvider.notifier).handleUnauthorized();
      }
      return CreateOrderResult.failure(
        message: error.message,
        statusCode: error.statusCode,
        fieldErrors: error.fieldErrors,
      );
    } catch (_) {
      return const CreateOrderResult.failure(
        message: "No fue posible guardar el pedido en el dispositivo.",
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
