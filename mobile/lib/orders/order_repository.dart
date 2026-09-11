import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';

/// One pending order per account. A sent request is never replayed after an
/// ambiguous failure: this backend does not implement idempotency.
class OrderLocalDataSource {
  static const _storage = FlutterSecureStorage();
  String _key(String user) => 'deliverpuyo.outbox.v1.$user';
  Future<Map<String, dynamic>?> read(String user) async {
    final value = await _storage.read(key: _key(user));
    return value == null ? null : jsonDecode(value) as Map<String, dynamic>;
  }

  Future<void> write(String user, OrderDraft draft, String status) =>
      _storage.write(
        key: _key(user),
        value: jsonEncode({
          'addressId': draft.addressId,
          'productId': draft.productId,
          'quantity': draft.quantity,
          'status': status,
        }),
      );
  Future<void> clear(String user) => _storage.delete(key: _key(user));
}

class OrderRepository {
  OrderRepository(this.api, this.local, {this.isCurrentUser});
  final ApiService api;
  final OrderLocalDataSource local;
  final bool Function(String)? isCurrentUser;
  bool _busy = false;
  static OrderDraft draft(Map<String, dynamic> value) => OrderDraft(
    addressId: value['addressId'] as String,
    productId: value['productId'] as String,
    quantity: value['quantity'] as String,
  );

  Future<OrderSummary> create(
    String user,
    String token,
    OrderDraft input,
  ) async {
    if (_busy) {
      throw const ApiException(message: 'Ya se está enviando un pedido.');
    }
    _busy = true;
    try {
      final previous = await local.read(user);
      _checkUser(user);
      if (previous != null && previous['status'] == 'sending') {
        throw const ApiException(
          message:
              'El resultado del envío anterior es incierto. Revisa tus pedidos antes de volver a crear uno.',
        );
      }
      if (previous != null) input = draft(previous);
      // Read-only preflight. Failure here guarantees POST was not attempted.
      try {
        await api.getOrders(token);
      } on ApiException catch (e) {
        _checkUser(user);
        if (e.statusCode != null) rethrow;
        await local.write(user, input, 'pending');
        throw const ApiException(
          message:
              'Sin conexión. Pedido pendiente guardado; se enviará al actualizar Pedidos con conexión.',
        );
      }
      _checkUser(user);
      await local.write(user, input, 'sending');
      try {
        final order = await api.createOrder(token: token, draft: input);
        await local.clear(user);
        return order;
      } on ApiException catch (e) {
        if (e.statusCode != null &&
            e.statusCode! >= 400 &&
            e.statusCode! < 500) {
          await local.clear(user);
          rethrow;
        }
        throw const ApiException(
          message:
              'No se pudo confirmar el envío. Revisa tus pedidos; no se reenviará automáticamente para evitar duplicados.',
        );
      }
    } finally {
      _busy = false;
    }
  }

  void _checkUser(String user) {
    if (isCurrentUser != null && !isCurrentUser!(user)) {
      throw const ApiException(
        message: 'La sesión cambió. Abre nuevamente tus pedidos.',
      );
    }
  }

  Future<void> discard(String user) async {
    if (_busy) {
      throw const ApiException(message: 'Espera a que termine el envío.');
    }
    _checkUser(user);
    await local.clear(user);
  }

  Future<void> synchronize(String user, String token) async {
    if (_busy) return;
    final value = await local.read(user);
    if (value != null && value['status'] == 'pending') {
      await create(user, token, draft(value));
    }
  }
}
