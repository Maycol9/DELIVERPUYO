import 'package:flutter/foundation.dart';

class ApiConfig {
  static const environment = String.fromEnvironment(
    'AMBIENTE',
    defaultValue: 'dev',
  );
  static bool get loggingEnabled => environment == 'dev' && !kReleaseMode;
  static void validate({String url = baseUrl, String ambiente = environment}) {
    final uri = Uri.parse(url);
    if (!['dev', 'test', 'staging', 'prod'].contains(ambiente) ||
        !uri.hasAuthority ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.scheme != 'https' &&
            !(ambiente == 'dev' &&
                !kReleaseMode &&
                uri.scheme == 'http' &&
                ['10.0.2.2', 'localhost', '127.0.0.1'].contains(uri.host)))) {
      throw StateError('Configura API_URL HTTPS para este ambiente.');
    }
  }

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: kIsWeb ? 'http://127.0.0.1:3000' : 'http://10.0.2.2:3000',
  );
}
