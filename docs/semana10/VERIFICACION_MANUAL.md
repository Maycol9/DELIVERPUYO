# Verificación manual Semana 10

## TalkBack

ACCIÓN MANUAL REQUERIDA

1. En Android, abrir Configuración.
2. Entrar en Accesibilidad.
3. Entrar en TalkBack.
4. Activar TalkBack.
5. Abrir DeliverPuyo.
6. Recorrer el título.
7. Verificar campo `Buscar producto`.
8. Verificar botón `PROBAR CONEXIÓN CON API`.
9. Verificar una tarjeta `ProductCard`.
10. Verificar botón `REINTENTAR` ejecutando con `UI_DEMO_STATE=error`.
11. Verificar iconos.
12. Registrar cualquier elemento anunciado como "botón sin nombre".

- [ ] TalkBack activado.
- [ ] Abrir DeliverPuyo.
- [ ] Verificar título.
- [ ] Verificar campo Buscar producto.
- [ ] Verificar botón Probar conexión con API.
- [ ] Verificar ProductCard.
- [ ] Verificar Reintentar.
- [ ] Verificar iconos.
- [ ] Confirmar que ningún botón sea anunciado sin nombre.
- [ ] Los iconos interactivos tienen etiqueta.
- [ ] Confirmar orden lógico.

## Fuente ampliada

ACCIÓN MANUAL REQUERIDA

- [ ] Aumentar el tamaño de fuente del sistema.
- [ ] Abrir DeliverPuyo.
- [ ] Verificar título.
- [ ] Verificar buscador.
- [ ] Verificar botones.
- [ ] Verificar ProductCard.
- [ ] Verificar que no haya clipping.
- [ ] Verificar que no exista superposición.

## Dos anchos

ACCIÓN MANUAL REQUERIDA

## Estados demostrables

No borrar datos reales. Usar `UI_DEMO_STATE` solo para capturas:

```powershell
flutter run -d edge --web-port=8081 --dart-define=API_URL=http://localhost:3000 --dart-define=UI_DEMO_STATE=loading
flutter run -d edge --web-port=8081 --dart-define=API_URL=http://localhost:3000 --dart-define=UI_DEMO_STATE=empty
flutter run -d edge --web-port=8081 --dart-define=API_URL=http://localhost:3000 --dart-define=UI_DEMO_STATE=error
flutter run -d edge --web-port=8081 --dart-define=API_URL=http://localhost:3000 --dart-define=UI_DEMO_STATE=normal
```

## Convención de nombres

- `01_api_products_backend.png`
- `02_catalogo_con_datos.png`
- `03_estado_cargando.png`
- `04_estado_vacio.png`
- `05_estado_error.png`
- `06_ancho_telefono.png`
- `07_segundo_ancho.png`
- `08_fuente_ampliada.png`
- `09_talkback.png`
- `10_tokens.png`
- `11_componentes.png`
- `12_flutter_analyze.png`
- `13_flutter_test.png`

Captura A, teléfono:

1. Ejecutar en el AVD `DeliverPuyo_API_36`.
2. Abrir la pantalla Catálogo de productos.
3. Guardar captura como `evidence/semana10/06_ancho_telefono.png`.

Captura B, ancho mayor:

1. Cambiar orientación del emulador o usar un emulador tipo tableta.
2. Abrir la misma pantalla.
3. Verificar que aparecen dos o más columnas cuando el ancho lo permite.
4. Guardar captura como `evidence/semana10/07_segundo_ancho.png`.
