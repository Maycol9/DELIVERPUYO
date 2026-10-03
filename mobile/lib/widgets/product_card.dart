import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.category,
    this.imageUrl,
    this.onTap,
    this.trailing,
    this.compact = false,
    super.key,
  });

  final String name;
  final double price;
  final int stock;
  final String? description;
  final String? category;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = Theme.of(context).colorScheme;
    final priceText = '\$${price.toStringAsFixed(2)}';
    final stockText = stock > 0 ? '$stock disponibles' : 'Sin stock';

    return Semantics(
      button: onTap != null,
      label:
          'Producto $name, ${category ?? 'sin categoría'}, precio $priceText, $stockText',
      child: Card(
        elevation: 1,
        shadowColor: colors.shadow.withAlpha(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tokens.radiusCard),
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceMd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(imageUrl: imageUrl, compact: compact),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (category != null) ...[
                        SizedBox(height: tokens.spaceXs),
                        _CategoryPill(label: category!),
                      ],
                      if (description != null && !compact) ...[
                        SizedBox(height: tokens.spaceSm),
                        Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      SizedBox(height: tokens.spaceMd),
                      Text(
                        priceText,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: colors.primary),
                      ),
                      SizedBox(height: tokens.spaceXs),
                      Row(
                        children: [
                          Icon(
                            stock > 0
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            size: 16,
                            color: stock > 0
                                ? AppColors.colorSuccess
                                : colors.error,
                          ),
                          SizedBox(width: tokens.spaceXs),
                          Expanded(
                            child: Text(
                              stockText,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.colorTextSecondary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: tokens.spaceSm),
                  IconTheme.merge(
                    data: IconThemeData(color: colors.primary, size: 22),
                    child: trailing!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spaceSm,
        vertical: tokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.colorSurfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radiusButton),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.colorTextSecondary),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl, required this.compact});

  final String? imageUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 64.0 : 72.0;
    final tokens = context.tokens;
    final colors = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.colorSurfaceVariant,
          borderRadius: BorderRadius.circular(tokens.radiusCard),
          border: Border.all(color: colors.primary.withAlpha(28)),
        ),
        child: Icon(
          Icons.local_mall_outlined,
          color: colors.primary,
          semanticLabel: 'Imagen no disponible',
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusCard),
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: AppColors.colorSurfaceVariant,
          child: Icon(
            Icons.broken_image_outlined,
            color: colors.primary,
            semanticLabel: 'Imagen no disponible',
          ),
        ),
      ),
    );
  }
}
