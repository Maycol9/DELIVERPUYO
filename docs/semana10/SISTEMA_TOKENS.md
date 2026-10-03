# Sistema de tokens Semana 10

## Tokens primitivos

| Token | Valor | Uso base |
| ----- | ----- | -------- |
| `green800` | `#006C57` | Verde principal con contraste AA. |
| `green700` | `#0E7C66` | Verde heredado de Semana 9. |
| `green100` | `#DDF4EE` | Fondo suave de imagen/estado. |
| `blue700` | `#2457A6` | Información. |
| `amber700` | `#9A6500` | Advertencias. |
| `red700` | `#B3261E` | Errores. |
| `white` | `#FFFFFF` | Superficies y texto sobre primario. |
| `gray50` | `#F7FAF9` | Fondo general. |
| `gray100` | `#E8EFEC` | Variantes suaves. |
| `gray500` | `#82918C` | Bordes accesibles. |
| `gray600` | `#52615D` | Texto secundario. |
| `gray900` | `#17211F` | Texto principal. |

## Tokens semánticos

| Token | Primitivo | Función |
| ----- | --------- | ------- |
| `colorPrimary` | `green800` | Marca y acciones principales. |
| `colorOnPrimary` | `white` | Texto sobre primario. |
| `colorBackground` | `gray50` | Fondo de pantalla. |
| `colorSurface` | `white` | Tarjetas y campos. |
| `colorSurfaceVariant` | `green100` | Contenedores suaves. |
| `colorTextPrimary` | `gray900` | Lectura principal. |
| `colorTextSecondary` | `gray600` | Lectura secundaria. |
| `colorError` | `red700` | Estados de error. |
| `colorSuccess` | `green800` | Estados correctos. |
| `colorWarning` | `amber700` | Advertencias. |
| `colorInfo` | `blue700` | Mensajes informativos. |
| `colorOutline` | `gray500` | Bordes de componentes. |

## Tokens de estructura

| Grupo | Valores |
| ----- | ------- |
| Espaciado | `xs=4`, `sm=8`, `md=16`, `lg=24`, `xl=32` |
| Radios | `field=8`, `button=8`, `card=8` |
| Animación | `durationFast=180ms` |

Los tokens de estructura están implementados como `ThemeExtension<AppTokens>` con `copyWith()` y `lerp()`.
