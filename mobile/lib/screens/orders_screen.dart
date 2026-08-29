import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/order.dart';
import '../orders/orders_controller.dart';
import '../state/remote_state.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/state_view.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        leading: IconButton(
          tooltip: 'Productos',
          onPressed: () => context.go('/products'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo pedido',
        onPressed: () => context.go('/orders/new'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.tokens.spaceMd),
          child: _OrdersBody(
            state: state,
            onRetry: () => ref.read(ordersControllerProvider.notifier).load(),
          ),
        ),
      ),
    );
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody({required this.state, required this.onRetry});

  final RemoteState<List<OrderSummary>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return switch (state) {
      RemoteInitial<List<OrderSummary>>() ||
      RemoteLoading<List<OrderSummary>>() => const StateView(
        type: StateViewType.loading,
        title: 'Cargando pedidos',
        message: 'Consultando tus pedidos...',
      ),
      RemoteError<List<OrderSummary>>(:final message) => StateView(
        type: StateViewType.error,
        title: 'No se pudieron cargar los pedidos',
        message: message,
        onRetry: onRetry,
      ),
      RemoteEmpty<List<OrderSummary>>(:final message) => StateView(
        type: StateViewType.empty,
        title: 'Sin pedidos',
        message: message,
        child: AppPrimaryButton(
          text: 'CREAR PEDIDO',
          onPressed: () => context.go('/orders/new'),
          icon: const Icon(Icons.add_shopping_cart),
        ),
      ),
      RemoteData<List<OrderSummary>>(:final value) => ListView.separated(
        itemCount: value.length,
        separatorBuilder: (_, _) => SizedBox(height: tokens.spaceSm),
        itemBuilder: (context, index) {
          final order = value[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text('Pedido ${order.id.substring(0, 8)}'),
              subtitle: Text('${order.status} · ${order.createdAt}'),
              trailing: Text('\$${order.total.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    };
  }
}
