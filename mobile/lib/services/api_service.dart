import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/product.dart';
import 'api_error_translator.dart';

class ApiResult {
  const ApiResult({
    required this.success,
    required this.message,
    this.statusCode,
    this.preview,
  });

  final bool success;
  final String message;
  final int? statusCode;
  final String? preview;
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 10);

  Future<ApiResult> getCategories() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/categories');

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        return ApiResult(
          success: false,
          statusCode: response.statusCode,
          message: ApiErrorTranslator.fromStatusCode(response.statusCode),
        );
      }

      return ApiResult(
        success: true,
        statusCode: response.statusCode,
        message: 'Conexión exitosa',
        preview: _buildPreview(response.body),
      );
    } catch (error) {
      return ApiResult(
        success: false,
        message: ApiErrorTranslator.fromException(error),
      );
    }
  }

  Future<ProductListResult> getProducts() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/products?page=1&limit=20'
      '&fields=id,name,price,stock,imageUrl,category',
    );

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        return ProductListResult.failure(
          ApiErrorTranslator.fromStatusCode(response.statusCode),
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const ProductListResult.failure(
          'La respuesta de productos no tiene el formato esperado.',
        );
      }

      final rawData = decoded['data'];
      final products = rawData is List
          ? rawData
                .whereType<Map<String, dynamic>>()
                .map(Product.fromJson)
                .toList(growable: false)
          : <Product>[];

      final pagination = decoded['pagination'];
      final totalItems = pagination is Map<String, dynamic>
          ? _toInt(pagination['total'])
          : products.length;

      return ProductListResult.success(products, totalItems: totalItems);
    } catch (error) {
      return ProductListResult.failure(ApiErrorTranslator.fromException(error));
    }
  }

  String _buildPreview(String body) {
    final decoded = jsonDecode(body);
    const encoder = JsonEncoder.withIndent('  ');
    final formatted = encoder.convert(decoded);

    if (formatted.length <= 600) return formatted;
    return '${formatted.substring(0, 600)}...';
  }

  int _toInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ProductListResult {
  const ProductListResult._({
    required this.success,
    required this.products,
    required this.message,
    required this.totalItems,
    this.statusCode,
  });

  final bool success;
  final List<Product> products;
  final String message;
  final int totalItems;
  final int? statusCode;

  const ProductListResult.success(List<Product> products, {int? totalItems})
    : this._(
        success: true,
        products: products,
        message: 'Productos cargados',
        totalItems: totalItems ?? products.length,
      );

  const ProductListResult.failure(String message, {int? statusCode})
    : this._(
        success: false,
        products: const [],
        message: message,
        totalItems: 0,
        statusCode: statusCode,
      );
}
