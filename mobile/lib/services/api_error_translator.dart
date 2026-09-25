import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

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
    if (error is DioException) {
      if ([
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      ].contains(error.type)) {
        return 'El servidor tardó demasiado en responder. Inténtalo nuevamente.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Sin conexión. Inténtalo nuevamente.';
      }
    }
    if (error is TimeoutException) {
      return 'La solicitud tardó demasiado. Intenta nuevamente.';
    }
    if (error is SocketException) {
      return 'No fue posible conectarse con el servidor.';
    }
    if (error is FormatException) {
      return 'La respuesta del servidor no pudo procesarse.';
    }
    return 'Ocurrió un problema inesperado. Intenta nuevamente.';
  }
}
