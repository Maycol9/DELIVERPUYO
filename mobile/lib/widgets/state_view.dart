import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_primary_button.dart';

enum StateViewType { loading, empty, error }

class StateView extends StatelessWidget {
  const StateView({
    required this.type,
    required this.message,
    this.onRetry,
    this.title,
    this.actionText = 'REINTENTAR',
    this.child,
    super.key,
  });

  final StateViewType type;
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final String actionText;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final icon = switch (type) {
      StateViewType.loading => Icons.hourglass_top,
      StateViewType.empty => Icons.inventory_2_outlined,
      StateViewType.error => Icons.error_outline,
    };
    final color = switch (type) {
      StateViewType.loading => Theme.of(context).colorScheme.primary,
      StateViewType.empty => AppColors.colorInfo,
      StateViewType.error => Theme.of(context).colorScheme.error,
    };
    final semanticLabel = switch (type) {
      StateViewType.loading => 'Estado cargando. $message',
      StateViewType.empty => 'Estado vacío. $message',
      StateViewType.error => 'Estado error. $message',
    };

    return Semantics(
      label: semanticLabel,
      liveRegion: type != StateViewType.empty,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type == StateViewType.loading)
                const CircularProgressIndicator()
              else
                Icon(icon, size: 40, color: color, semanticLabel: title),
              SizedBox(height: tokens.spaceMd),
              if (title != null) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spaceSm),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (child != null) ...[SizedBox(height: tokens.spaceMd), child!],
              if (type == StateViewType.error && onRetry != null) ...[
                SizedBox(height: tokens.spaceLg),
                AppPrimaryButton(
                  text: actionText,
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
