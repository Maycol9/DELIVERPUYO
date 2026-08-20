import 'package:flutter/material.dart';

import 'services/api_service.dart';

void main() {
  runApp(const DeliverPuyoApp());
}

class DeliverPuyoApp extends StatelessWidget {
  const DeliverPuyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeliverPuyo Móvil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7C66)),
        useMaterial3: true,
      ),
      home: const ApiTestPage(),
    );
  }
}

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final ApiService _apiService = ApiService();
  bool _loading = false;
  String _status = 'Conexión no probada';
  String _details = 'Presiona el botón para consultar el backend real.';

  Future<void> _testConnection() async {
    setState(() {
      _loading = true;
      _status = 'Consultando API...';
      _details = 'Enviando solicitud GET al backend DeliverPuyo.';
    });

    final result = await _apiService.getCategories();

    if (!mounted) return;

    setState(() {
      _loading = false;
      if (result.success) {
        _status = 'Conexión exitosa';
        _details = 'Código HTTP: ${result.statusCode}\n${result.preview}';
      } else {
        _status = 'No se pudo conectar';
        _details = result.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeliverPuyo Móvil'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'DeliverPuyo Móvil',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cliente móvil del proyecto DeliverPuyo para verificar la configuración Flutter, Android y la conexión HTTP con la API REST existente.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _loading ? null : _testConnection,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_sync),
                label: const Text('PROBAR CONEXIÓN CON API'),
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: resultColor(colors),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _details,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color resultColor(ColorScheme colors) {
    if (_loading) return colors.primary;
    if (_status == 'Conexión exitosa') return colors.primary;
    if (_status == 'No se pudo conectar') return colors.error;
    return colors.onSurface;
  }
}
