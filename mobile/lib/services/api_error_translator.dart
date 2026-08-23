import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiErrorTranslator {
  const ApiErrorTranslator._();

  static String fromStatusCode(int statusCode) {
    return switch (statusCode) {
      401 => 'Tu sesión terminó. Inicia sesión nuevamente.',
      403 => 'No tienes permiso para realizar esta acción.',
      404 => 'La información solicitada ya no está disponible.',
      409 => 'Existe un conflicto con la información enviada.',
      422 => 'Revisa los datos ingresados.',
      >= 500 => 'Ocurrió un problema temporal. Intenta nuevamente.',
      _ => 'No fue posible completar la solicitud. Intenta nuevamente.',
    };
  }

  static String fromException(Object error) {
    if (error is TimeoutException) {
      return 'La solicitud tardó demasiado. Intenta nuevamente.';
    }
    if (error is SocketException || error is http.ClientException) {
      return 'No fue posible conectarse con el servidor.';
    }
    if (error is FormatException) {
      return 'La respuesta del servidor no pudo procesarse.';
    }
    return 'Ocurrió un problema inesperado. Intenta nuevamente.';
  }
}
