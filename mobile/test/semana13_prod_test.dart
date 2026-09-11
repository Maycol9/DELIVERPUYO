import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deliverpuyo_mobile/config/api_config.dart';
import 'package:deliverpuyo_mobile/services/api_client.dart';

void main() {
  test(
    'production logging remains off even when requested',
    () async {
      expect(ApiConfig.environment, 'prod');
      expect(ApiConfig.loggingEnabled, isFalse);
      final lines = <String>[];
      final client = ApiClient(logging: true, logger: lines.add);
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) =>
              h.resolve(Response(requestOptions: o, statusCode: 200, data: {})),
        ),
      );
      await client.dio.get('/api/products');
      expect(lines, isEmpty);
    },
    skip: ApiConfig.environment != 'prod',
  );
}
