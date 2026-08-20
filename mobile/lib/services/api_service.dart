import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

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
          message: 'La API respondió con código HTTP ${response.statusCode}.',
        );
      }

      return ApiResult(
        success: true,
        statusCode: response.statusCode,
        message: 'Conexión exitosa',
        preview: _buildPreview(response.body),
      );
    } on TimeoutException {
      return const ApiResult(
        success: false,
        message: 'La API no respondió dentro del tiempo esperado.',
      );
    } on http.ClientException {
      return const ApiResult(
        success: false,
        message: 'No fue posible establecer conexión con el backend.',
      );
    } on FormatException {
      return const ApiResult(
        success: false,
        message: 'La URL de la API no tiene un formato válido.',
      );
    } catch (_) {
      return const ApiResult(
        success: false,
        message: 'Ocurrió un error inesperado al consultar la API.',
      );
    }
  }

  String _buildPreview(String body) {
    final decoded = jsonDecode(body);
    const encoder = JsonEncoder.withIndent('  ');
    final formatted = encoder.convert(decoded);

    if (formatted.length <= 600) return formatted;
    return '${formatted.substring(0, 600)}...';
  }
}
