# Contraste WCAG 2.2

Mediciones calculadas con luminancia relativa WCAG sobre los tokens reales en `mobile/lib/theme/app_colors.dart`.

| Primer color | Segundo color | Relación | Requisito | Resultado |
| ------------ | ------------- | -------: | --------: | --------- |
| `colorPrimary` `#006C57` | `colorOnPrimary` `#FFFFFF` | 6.40:1 | 4.5:1 | Cumple AA |
| `colorTextPrimary` `#17211F` | `colorBackground` `#F7FAF9` | 15.70:1 | 4.5:1 | Cumple AA |
| `colorTextSecondary` `#52615D` | `colorBackground` `#F7FAF9` | 6.20:1 | 4.5:1 | Cumple AA |
| `colorError` `#B3261E` | `colorSurface` `#FFFFFF` | 6.54:1 | 4.5:1 | Cumple AA |
| `colorSuccess` `#006C57` | `colorSurface` `#FFFFFF` | 6.40:1 | 4.5:1 | Cumple AA |
| `colorWarning` `#9A6500` | `colorSurface` `#FFFFFF` | 4.96:1 | 4.5:1 | Cumple AA |
| `colorInfo` `#2457A6` | `colorSurface` `#FFFFFF` | 7.03:1 | 4.5:1 | Cumple AA |
| `colorOutline` `#82918C` | `colorSurface` `#FFFFFF` | 3.29:1 | 3:1 | Cumple AA para componentes |

## Ajuste realizado

El borde inicial `colorOutline` usaba `#E8EFEC` y alcanzaba 1.17:1 contra blanco. Se ajustó mínimamente a `#82918C` para que los contornos de componentes importantes superen 3:1.
