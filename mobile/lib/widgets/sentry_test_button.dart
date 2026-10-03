import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../config/sentry_config.dart';
import '../services/sentry_service.dart';

class SentryTestButton extends StatefulWidget {
  const SentryTestButton({super.key, this.capture});

  // Injection permits widget tests without generating an exception or event.
  final Future<SentryId?> Function()? capture;

  @override
  State<SentryTestButton> createState() => _SentryTestButtonState();
}

class _SentryTestButtonState extends State<SentryTestButton> {
  bool _busy = false;
  String? _result;

  Future<void> _capture() async {
    if (_busy || !SentryConfig.crashEnabled || !SentryConfig.isEnabled) return;
    setState(() => _busy = true);
    try {
      final id = await (widget.capture ?? SentryService.triggerTestCrash)();
      if (!mounted) return;
      setState(
        () => _result = id == null || id == SentryId.empty()
            ? 'El SDK no devolvió un identificador de evento.'
            : 'Evento: $id. Comprueba su recepción en Sentry.',
      );
    } catch (_) {
      if (mounted) setState(() => _result = 'No se pudo completar la captura.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SentryConfig.crashEnabled) return const SizedBox.shrink();
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: SentryConfig.isEnabled && !_busy ? _capture : null,
          icon: const Icon(Icons.bug_report_outlined),
          label: Text(_busy ? 'Procesando…' : 'Probar Sentry (desarrollo)'),
        ),
        if (!SentryConfig.isEnabled) const Text('Sentry no está configurado.'),
        if (_result != null) SelectableText(_result!),
      ],
    );
  }
}
