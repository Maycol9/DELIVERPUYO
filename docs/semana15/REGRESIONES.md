# Regresiones verificadas

## Pedido inválido enviado desde el repositorio

Se escribió primero `mobile/test/semana15_validation_test.dart`. La ejecución real previa a corregir código terminó con 73 casos aprobados, 8 fallidos y 1 omisión condicional. Los ocho casos inválidos devolvían OrderSummary desde el doble de transporte, cuando debían rechazar el borrador. Evidencia: `evidence/semana15/regression-before.txt`.

La UI ya validaba; la entrada directa a `OrderRepository.create` y el reenvío de un borrador persistido carecían de esa barrera. Se agregó validación de dirección/producto no vacíos y cantidad entera entre 1 y 50, después de recuperar el pendiente y antes del preflight, escritura y POST. Se devuelve ApiException con errores por campo, sin cambiar el contrato HTTP. No se modifica el diagnóstico DEV 422, que intencionalmente usa otra ruta interna.

Tras corregir: los 11 casos de ese archivo pasan (ocho inválidos y tres cantidades válidas: 1, 2 y 50). Las aserciones verifican ausencia de GET/POST y de escritura outbox para entradas inválidas; para válidas comprueban envío único y limpieza local. La suite completa conserva todas las pruebas previas.

Este fallo reproducido justifica el cambio mínimo en el repositorio de Semana 13. No se cambió backend, Prisma, BD ni .env.

## Desbordamiento de selectores en pantalla estrecha

La E2E ejecutada en Android detectó RenderFlex overflow al mostrar la dirección. Antes de corregir el formulario se añadió `selected order fields fit a 320 pixel wide screen` en `semana15_form_test.dart`. Falló con dos desbordamientos en los selectores de dirección y producto (`create_order_screen.dart`). Salida real conservada en `evidence/semana15/overflow-before.txt`.

Corrección mínima: `isExpanded: true` en ambos selectores y texto limitado a una línea con elipsis. No se cambian datos, validadores ni envío. La regresión y los tres casos inválidos del formulario pasan: 4 pruebas, 0 fallos. Esto justifica tocar exclusivamente esos controles de la pantalla preexistente. No es una optimización de rendimiento ni una medición de fluidez.

## Ajustes de pruebas durante su desarrollo

El test nuevo del catálogo necesitó completar el scroll y corregir la espera de cancelación de su stream falso. El E2E necesitó sincronizar la carga de direcciones, sacar comprobaciones del callback HTTP y comprobar el ID abreviado que la UI realmente presenta. Son ajustes del doble y de las aserciones, no bugs de producción. Dos intentos E2E se interrumpieron por desconexión del emulador; se reinició sin snapshots y con renderizado software, sin borrar datos.
