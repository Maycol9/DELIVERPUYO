import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      const allowed = {
        '01_login',
        '02_productos_backend_real',
        '09_online_catalogo',
        '12_seguridad_configuracion',
      };
      if (!allowed.contains(name)) return false;
      await File('../evidence/semana13/$name.png').writeAsBytes(bytes);
      return true;
    },
  );
}
