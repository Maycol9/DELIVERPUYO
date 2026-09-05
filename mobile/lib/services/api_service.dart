import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
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
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 10);
  final http.Client _client;

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
    try {
      final decoded = await _request(
        'GET',
        '/api/products',
        query: const {
          'page': '1',
          'limit': '50',
          'fields': 'id,name,description,price,stock,imageUrl,category',
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
    return AuthSession(
      user: AppUser.fromJson(_asMap(data['user'])),
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
      expiresInSeconds: _toInt(data['expiresInSeconds']),
    );
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
    return AuthSession(
      user: AppUser.fromJson(_asMap(data['user'])),
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
      expiresInSeconds: _toInt(data['expiresInSeconds']),
    );
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
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = switch (method) {
        'GET' => await _client.get(uri, headers: headers).timeout(_timeout),
        'POST' =>
          await _client
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(_timeout),
        _ => throw UnsupportedError('Metodo HTTP no soportado: $method'),
      };
      return _decodeResponse(response);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException(message: ApiErrorTranslator.fromException(error));
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta del servidor no tiene el formato esperado.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromStatus(
        response.statusCode,
        serverMessage: decoded['message']?.toString(),
        errors: decoded['errors'],
      );
    }
    return decoded;
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
