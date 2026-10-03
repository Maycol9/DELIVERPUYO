# Integración continua

Se encontró el remoto GitHub y no había workflows. Se añadió `.github/workflows/flutter_tests.yml` con Flutter 3.44.4 (la versión local verificada), pub get, analyze, test --coverage y las comprobaciones de logging PROD. Usa permisos de lectura, no añade secretos, no publica ni despliega. Se conserva la omisión por entorno, pero el segundo comando ejecuta explícitamente la prueba omitida.

Configuración basada en el [README oficial de flutter-action](https://github.com/subosito/flutter-action/blob/main/README.md). Se usan actions/checkout@v6 y subosito/flutter-action@v2 en runner alojado Ubuntu. No se ha ejecutado en GitHub porque no se hizo commit ni push; no se atribuye al workflow el resultado de los comandos locales. La E2E Android se ejecuta separadamente, no se finge incluida en flutter test del CI.
