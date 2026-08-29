import 'api_error_translator.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  factory ApiException.fromStatus(
    int statusCode, {
    String? serverMessage,
    Object? errors,
  }) {
    final translated = ApiErrorTranslator.fromStatusCode(statusCode);
    return ApiException(
      statusCode: statusCode,
      message: statusCode == 422 ? (serverMessage ?? translated) : translated,
      fieldErrors: _parseFieldErrors(errors),
    );
  }

  static Map<String, String> _parseFieldErrors(Object? errors) {
    if (errors is! Map) return const {};

    final result = <String, String>{};
    for (final entry in errors.entries) {
      final key = entry.key?.toString();
      final value = entry.value;
      if (key == null || key.isEmpty) continue;
      if (value is List && value.isNotEmpty) {
        result[key] = value.first.toString();
      } else if (value is String && value.isNotEmpty) {
        result[key] = value;
      }
    }
    return result;
  }
}
