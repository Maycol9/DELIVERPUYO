import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.icon,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isEnabled = enabled && !loading && onPressed != null;

    final label = Text(
      text,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.center,
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: loading ? '$text, cargando' : text,
      child: FilledButton(
        onPressed: isEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spaceMd,
            vertical: tokens.spaceSm,
          ),
        ),
        child: AnimatedSwitcher(
          duration: tokens.durationFast,
          child: loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : Row(
                  key: const ValueKey('content'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      SizedBox(width: tokens.spaceSm),
                    ],
                    Flexible(child: label),
                  ],
                ),
        ),
      ),
    );
  }
}
