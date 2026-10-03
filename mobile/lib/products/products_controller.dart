import 'package:dio/dio.dart';
import 'product_repository.dart';
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
  int _generation = 0;
  bool _disposed = false;
  void cancel() {
    _generation++;
    ref.read(apiServiceProvider).cancelProducts();
  }

  @override
  RemoteState<List<Product>> build() {
    ref.onDispose(() {
      _disposed = true;
    });
    Future.microtask(load);
    return const RemoteInitial();
  }

  Future<void> load() async {
    final generation = ++_generation;
    ref.read(apiServiceProvider).cancelProducts();
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

    final repository = ProductRepository(
      ProductRemoteDataSource(ref.read(apiServiceProvider)),
      ProductLocalDataSource(),
    );
    try {
      await for (final result in repository.watch()) {
        if (_disposed || generation != _generation) return;
        state = result.error != null
            ? RemoteError(result.error!, statusCode: result.statusCode)
            : result.products.isEmpty
            ? const RemoteEmpty('No hay productos disponibles en este momento.')
            : RemoteData(result.products, notice: result.notice);
      }
    } on DioException catch (e) {
      if (!CancelToken.isCancel(e) && !_disposed && generation == _generation) {
        state = const RemoteError('No fue posible cargar los productos.');
      }
    }
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
