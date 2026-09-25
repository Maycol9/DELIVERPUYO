import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class CategoryFilterChip extends StatelessWidget {
  const CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, filtro seleccionado' : '$label, filtro',
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        showCheckmark: true,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected ? colors.onPrimary : colors.onSurface,
        ),
        backgroundColor: colors.surface,
        selectedColor: colors.primary,
        side: BorderSide(
          color: selected ? colors.primary : colors.outline.withAlpha(120),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusButton),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceSm,
          vertical: tokens.spaceXs,
        ),
      ),
    );
  }
}
