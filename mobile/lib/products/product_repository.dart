import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductLocalDataSource {
  static const _key = 'deliverpuyo.products.v1';
  Future<List<Product>?> read() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return null;
      return (jsonDecode(raw) as List).map((e) => Product.fromJson(e)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> write(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(products.map((e) => e.toJson()).toList()),
    );
  }
}

class ProductRemoteDataSource {
  const ProductRemoteDataSource(this.api);
  final ApiService api;
  Future<ProductListResult> read() => api.getProducts();
  void cancel() => api.cancelProducts();
}

class ProductSnapshot {
  const ProductSnapshot(
    this.products, {
    this.notice,
    this.error,
    this.statusCode,
  });
  final List<Product> products;
  final String? notice;
  final String? error;
  final int? statusCode;
}

class ProductRepository {
  const ProductRepository(this.remote, this.local);
  final ProductRemoteDataSource remote;
  final ProductLocalDataSource local;
  Stream<ProductSnapshot> watch() async* {
    final cached = await local.read();
    if (cached != null) {
      yield ProductSnapshot(cached, notice: 'Datos guardados. Actualizando…');
    }
    final result = await remote.read();
    if (result.success) {
      String? notice;
      try {
        await local.write(result.products);
      } catch (_) {
        notice = 'Datos actuales; no fue posible guardarlos en el dispositivo.';
      }
      yield ProductSnapshot(result.products, notice: notice);
    } else if (cached != null) {
      yield ProductSnapshot(
        cached,
        notice:
            '${result.message} Se muestran datos guardados que pueden estar desactualizados.',
      );
    } else {
      yield ProductSnapshot(
        const [],
        error: result.message,
        statusCode: result.statusCode,
      );
    }
  }
}
