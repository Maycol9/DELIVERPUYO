import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../models/address.dart';
import '../providers/app_providers.dart';
import '../services/api_exception.dart';
import '../state/remote_state.dart';

final addressesProvider = FutureProvider<RemoteState<List<Address>>>((
  ref,
) async {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    return const RemoteError('Inicia sesión para ver tus direcciones.');
  }

  try {
    final addresses = await ref
        .read(apiServiceProvider)
        .getAddresses(session.accessToken);
    return addresses.isEmpty
        ? const RemoteEmpty('No tienes direcciones registradas.')
        : RemoteData(addresses);
  } on ApiException catch (error) {
    if (error.isUnauthorized) {
      ref.read(authControllerProvider.notifier).handleUnauthorized();
    }
    return RemoteError(error.message, statusCode: error.statusCode);
  }
});
