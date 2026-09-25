import 'dart:convert';

import 'package:dio/dio.dart';
import 'api_client.dart';

import '../models/address.dart';
import '../models/app_user.dart';
import '../models/auth_session.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'api_error_translator.dart';
import 'api_exception.dart';

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
  ApiService({ApiClient? client}) : client = client ?? ApiClient();
  final ApiClient client;
  CancelToken? productsCancelToken;
  void cancelProducts() => productsCancelToken?.cancel();

  Future<ApiResult> getCategories() async {
    try {
      final decoded = await _request('GET', '/api/categories');
      return ApiResult(
        success: true,
        statusCode: 200,
        message: 'Conexión exitosa',
        preview: _buildPreview(decoded),
      );
    } on ApiException catch (error) {
      return ApiResult(
        success: false,
        statusCode: error.statusCode,
        message: error.message,
      );
    } catch (error) {
      return ApiResult(
        success: false,
        message: ApiErrorTranslator.fromException(error),
      );
    }
  }

  Future<ProductListResult> getProducts() async {
    productsCancelToken = CancelToken();
    try {
      final decoded = await _request(
        'GET',
        '/api/products',
        cancelToken: productsCancelToken,
        query: const {
          'page': '1',
          'limit': '50',
          'fields': 'id,name,price,stock,imageUrl,category',
        },
      );

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
    } on ApiException catch (error) {
      return ProductListResult.failure(
        error.message,
        statusCode: error.statusCode,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      return ProductListResult.failure(ApiErrorTranslator.fromException(error));
    } catch (error) {
      return ProductListResult.failure(ApiErrorTranslator.fromException(error));
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final decoded = await _request(
      'POST',
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    final data = _dataMap(decoded);
    final session = AuthSession(
      user: AppUser.fromJson(_asMap(data['user'])),
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
      expiresInSeconds: _toInt(data['expiresInSeconds']),
    );
    await client.saveSession(session);
    return session;
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final decoded = await _request(
      'POST',
      '/api/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    final data = _dataMap(decoded);
    final session = AuthSession(
      user: AppUser.fromJson(_asMap(data['user'])),
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
      expiresInSeconds: _toInt(data['expiresInSeconds']),
    );
    await client.saveSession(session);
    return session;
  }

  Future<List<Address>> getAddresses(String token) async {
    final decoded = await _request('GET', '/api/addresses', token: token);
    final rawData = decoded['data'];
    return rawData is List
        ? rawData
              .whereType<Map<String, dynamic>>()
              .map(Address.fromJson)
              .toList(growable: false)
        : <Address>[];
  }

  Future<List<OrderSummary>> getOrders(String token) async {
    final decoded = await _request(
      'GET',
      '/api/orders',
      token: token,
      query: const {'page': '1', 'limit': '20'},
    );
    final rawData = decoded['data'];
    return rawData is List
        ? rawData
              .whereType<Map<String, dynamic>>()
              .map(OrderSummary.fromJson)
              .toList(growable: false)
        : <OrderSummary>[];
  }

  Future<OrderSummary> createOrder({
    required String token,
    required OrderDraft draft,
  }) async {
    final decoded = await _request(
      'POST',
      '/api/orders',
      token: token,
      body: draft.toCreateJson(),
    );
    return OrderSummary.fromJson(_dataMap(decoded));
  }

  Future<void> probeForbidden(String token) async {
    await _request(
      'POST',
      '/api/categories',
      token: token,
      body: const {'name': 'Semana once'},
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    String? token,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await client.dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancelToken,
        options: Options(method: method, extra: {'protected': token != null}),
      );
      final decoded = response.data;
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ApiException.fromStatus(
          status,
          errors: decoded is Map ? decoded['errors'] : null,
        );
      }
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respuesta inválida');
      }
      return decoded;
    } catch (error) {
      if (error is ApiException) rethrow;
      if (error is DioException && CancelToken.isCancel(error)) rethrow;
      throw ApiException(message: ApiErrorTranslator.fromException(error));
    }
  }

  String _buildPreview(Map<String, dynamic> decoded) {
    const encoder = JsonEncoder.withIndent('  ');
    final formatted = encoder.convert(decoded);

    if (formatted.length <= 600) return formatted;
    return '${formatted.substring(0, 600)}...';
  }

  Map<String, dynamic> _dataMap(Map<String, dynamic> decoded) {
    return _asMap(decoded['data']);
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const ApiException(
      message: 'La respuesta del servidor no tiene el formato esperado.',
    );
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
