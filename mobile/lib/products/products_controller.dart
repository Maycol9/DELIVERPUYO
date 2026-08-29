import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_demo_config.dart';
import '../models/product.dart';
import '../providers/app_providers.dart';
import '../state/remote_state.dart';

final productsControllerProvider =
    NotifierProvider<ProductsController, RemoteState<List<Product>>>(
      ProductsController.new,
    );

class ProductsController extends Notifier<RemoteState<List<Product>>> {
  @override
  RemoteState<List<Product>> build() {
    Future.microtask(load);
    return const RemoteInitial();
  }

  Future<void> load() async {
    state = const RemoteLoading();

    if (AppDemoConfig.state == UiDemoState.loading) return;

    if (AppDemoConfig.state == UiDemoState.empty) {
      state = const RemoteEmpty(
        'No hay productos disponibles en este momento.',
      );
      return;
    }

    if (AppDemoConfig.state == UiDemoState.error) {
      state = const RemoteError('No fue posible conectarse con el servidor.');
      return;
    }

    final result = await ref.read(apiServiceProvider).getProducts();
    if (!result.success) {
      state = RemoteError(result.message, statusCode: result.statusCode);
      return;
    }
    state = result.products.isEmpty
        ? const RemoteEmpty('No hay productos disponibles en este momento.')
        : RemoteData(result.products);
  }

  Product? byId(String productId) {
    final current = state;
    if (current is! RemoteData<List<Product>>) return null;
    for (final product in current.value) {
      if (product.id == productId) return product;
    }
    return null;
  }
}
