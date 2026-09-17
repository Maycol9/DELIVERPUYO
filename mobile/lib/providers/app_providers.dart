import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../models/order_evidence.dart';
import '../orders/evidence_store.dart';
import '../services/order_native_service.dart';
import '../auth/auth_controller.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final evidenceStoreProvider = Provider<EvidenceStore>((ref) => EvidenceStore());
final orderNativeServiceProvider = Provider<OrderNativeService>(
  (ref) => PluginOrderNativeService(),
);
final draftStorageErrorProvider = StateProvider<String?>((ref) => null);

final orderDraftProvider = NotifierProvider<OrderDraftController, OrderDraft>(
  OrderDraftController.new,
);

class OrderDraftController extends Notifier<OrderDraft> {
  Future<void> _writes = Future.value();
  int _revision = 0;
  String? _user;
  @override
  OrderDraft build() {
    _user = ref.watch(
      authControllerProvider.select((auth) => auth.session?.user.id),
    );
    final user = _user;
    final revision = ++_revision;
    if (user != null) {
      Future.microtask(() async {
        try {
          await _writes;
          final saved = await ref.read(evidenceStoreProvider).readDraft(user);
          if (_user == user && _revision == revision && saved != null) {
            state = saved;
          }
        } catch (_) {
          if (_user == user) {
            ref.read(draftStorageErrorProvider.notifier).state =
                'No se pudo recuperar el borrador local. Puedes continuar sin información opcional.';
          }
        }
      });
    }
    return const OrderDraft();
  }

  void _save() {
    _revision++;
    final user = _user;
    if (user == null) return;
    final draft = state;
    final store = ref.read(evidenceStoreProvider);
    _writes = _writes.then((_) => store.saveDraft(user, draft)).catchError((
      Object _,
    ) {
      if (_user == user) {
        ref.read(draftStorageErrorProvider.notifier).state =
            'No se pudo conservar el borrador en el dispositivo. Intenta nuevamente o continúa sin información opcional.';
      }
    });
  }

  void setAddress(String value) {
    state = state.copyWith(addressId: value);
    _save();
  }

  void setProduct(String value) {
    state = state.copyWith(productId: value);
    _save();
  }

  void setQuantity(String value) {
    state = state.copyWith(quantity: value);
    _save();
  }

  void setPhoto(OrderPhoto? value) {
    state = state.copyWith(photo: value, removePhoto: value == null);
    _save();
  }

  void setLocation(OrderLocation? value) {
    state = state.copyWith(location: value, removeLocation: value == null);
    _save();
  }

  Future<void> flush() => _writes;

  void clear() {
    state = const OrderDraft();
    _save();
  }
}
