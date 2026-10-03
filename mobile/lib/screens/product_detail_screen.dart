import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../products/products_controller.dart';
import '../state/remote_state.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/product_card.dart';
import '../widgets/state_view.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsControllerProvider);
    final product = ref
        .read(productsControllerProvider.notifier)
        .byId(productId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => context.go('/products'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.tokens.spaceMd),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _DetailBody(
                state: state,
                product: product,
                onRetry: () =>
                    ref.read(productsControllerProvider.notifier).load(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.state,
    required this.product,
    required this.onRetry,
  });

  final RemoteState<List<Product>> state;
  final Product? product;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return switch (state) {
      RemoteInitial<List<Product>>() ||
      RemoteLoading<List<Product>>() => const StateView(
        type: StateViewType.loading,
        title: 'Cargando producto',
        message: 'Consultando catálogo...',
      ),
      RemoteError<List<Product>>(:final message) => StateView(
        type: StateViewType.error,
        title: 'No se pudo cargar el producto',
        message: message,
        onRetry: onRetry,
      ),
      RemoteEmpty<List<Product>>() => const StateView(
        type: StateViewType.empty,
        title: 'Producto no disponible',
        message: 'El catálogo no tiene productos para mostrar.',
      ),
      RemoteData<List<Product>>() =>
        product == null
            ? const StateView(
                type: StateViewType.empty,
                title: 'Producto no encontrado',
                message: 'El identificador no existe en el catálogo actual.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductCard(
                    name: product!.name,
                    price: product!.price,
                    stock: product!.stock,
                    category: product!.categoryName,
                    imageUrl: product!.imageUrl,
                    description: product!.description,
                  ),
                  SizedBox(height: tokens.spaceLg),
                  AppPrimaryButton(
                    text: 'CREAR PEDIDO',
                    onPressed: () => context.go('/orders/new'),
                    icon: const Icon(Icons.add_shopping_cart),
                  ),
                ],
              ),
    };
  }
}
