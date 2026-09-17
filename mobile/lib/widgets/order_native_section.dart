import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import '../providers/app_providers.dart';
import '../services/order_native_service.dart';

class OrderNativeSection extends ConsumerStatefulWidget {
  const OrderNativeSection({
    super.key,
    this.enabled = true,
    this.onBusyChanged,
  });
  final bool enabled;
  final ValueChanged<bool>? onBusyChanged;
  @override
  ConsumerState<OrderNativeSection> createState() => _OrderNativeSectionState();
}

class _OrderNativeSectionState extends ConsumerState<OrderNativeSection>
    with WidgetsBindingObserver {
  bool _busy = false;
  bool _cameraAvailable = true;
  bool _locationAvailable = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recover());
  }

  Future<void> _recover() async {
    if (!mounted) return;
    final user = ref.read(authControllerProvider).session?.user.id;
    if (user == null) return;
    final store = ref.read(evidenceStoreProvider);
    final service = ref.read(orderNativeServiceProvider);
    try {
      if (!await store.hasPendingPicker(user) || !mounted || _busy) return;
      final path = await service.recoverPhoto();
      if (path == null) {
        await store.endPicker();
        return;
      }
      if (!mounted ||
          ref.read(authControllerProvider).session?.user.id != user) {
        return;
      }
      final photo = await store.importPhoto(user, path);
      if (!mounted ||
          ref.read(authControllerProvider).session?.user.id != user) {
        await store.deletePhoto(user, photo);
        return;
      }
      final controller = ref.read(orderDraftProvider.notifier);
      controller.setPhoto(photo);
      await controller.flush();
      await store.endPicker();
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'No se pudo recuperar la foto interrumpida. Puedes elegir otra o continuar sin fotografía.',
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Re-enable actions; actual OS state is checked again on explicit use.
      setState(() {
        _cameraAvailable = true;
        _locationAvailable = true;
      });
    }
  }

  Future<bool> _explain(bool camera) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(camera ? 'Fotografía opcional' : 'Ubicación opcional'),
          content: Text(
            camera
                ? 'DeliverPuyo necesita acceso a la cámara únicamente para tomar una foto relacionada con este pedido.'
                : 'DeliverPuyo utiliza tu ubicación actual únicamente como referencia para este pedido.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ) ??
      false;

  Future<bool> _permission(OrderNativeService service, bool camera) async {
    var status = camera
        ? await service.cameraPermission()
        : await service.locationPermission();
    if (status == NativePermission.denied) {
      status = camera
          ? await service.cameraPermission(request: true)
          : await service.locationPermission(request: true);
    }
    if (!mounted) return false;
    switch (status) {
      case NativePermission.granted:
        return true;
      case NativePermission.denied:
        setState(
          () => _message = camera
              ? 'No se concedió acceso a la cámara. Puedes continuar el pedido sin fotografía.'
              : 'No se concedió acceso a la ubicación. Puedes continuar el pedido sin ubicación.',
        );
        return false;
      case NativePermission.restricted:
        setState(() {
          if (camera) {
            _cameraAvailable = false;
          } else {
            _locationAvailable = false;
          }
          _message =
              'Esta función no está disponible. Puedes continuar el pedido sin ella.';
        });
        return false;
      case NativePermission.permanentlyDenied:
        final open = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permiso desactivado'),
            content: Text(
              camera
                  ? 'El permiso de cámara está desactivado permanentemente. Puedes habilitarlo desde los ajustes del dispositivo.'
                  : 'El permiso de ubicación está desactivado permanentemente. Puedes habilitarlo desde los ajustes del dispositivo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Abrir ajustes'),
              ),
            ],
          ),
        );
        if (open == true && mounted) {
          if (!await service.settings() && mounted) {
            setState(
              () => _message =
                  'Abre los ajustes del dispositivo manualmente. Puedes continuar sin esta función.',
            );
          }
        }
        return false;
    }
  }

  Future<void> _act({bool camera = false, bool location = false}) async {
    if (_busy) return;
    final user = ref.read(authControllerProvider).session?.user.id;
    if (user == null) return;
    final service = ref.read(orderNativeServiceProvider);
    final store = ref.read(evidenceStoreProvider);
    bool current() =>
        mounted && ref.read(authControllerProvider).session?.user.id == user;
    setState(() {
      _busy = true;
      _message = null;
    });
    widget.onBusyChanged?.call(true);
    try {
      if ((camera || location) && !await _explain(camera)) return;
      if (!current()) return;
      if (location) {
        if (!await service.locationEnabled()) {
          if (current()) {
            setState(
              () => _message =
                  'El servicio de ubicación del dispositivo está desactivado. Actívalo para usar esta función. Puedes continuar sin ubicación.',
            );
          }
          return;
        }
        if (!current() || !await _permission(service, false) || !current()) {
          return;
        }
        final position = await service.currentLocation();
        if (current()) {
          ref.read(orderDraftProvider.notifier).setLocation(position);
        }
      } else {
        if (camera && (!await _permission(service, true) || !current())) {
          return;
        }
        await ref.read(orderDraftProvider.notifier).flush();
        await store.beginPicker(user);
        final path = await service.pickPhoto(camera: camera);
        if (path == null || !current()) {
          return;
        }
        final photo = await store.importPhoto(user, path);
        if (!current()) {
          await store.deletePhoto(user, photo);
          return;
        }
        final previous = ref.read(orderDraftProvider).photo;
        final controller = ref.read(orderDraftProvider.notifier);
        controller.setPhoto(photo);
        await controller.flush();
        if (previous != null) {
          await store.deleteUnreferencedPhoto(user, previous);
        }
      }
    } on TimeoutException {
      if (current()) {
        setState(
          () => _message =
              'No se pudo obtener la ubicación a tiempo. Puedes reintentar o continuar sin ubicación.',
        );
      }
    } on PlatformException catch (error) {
      if (current()) {
        if (error.code == 'no_available_camera' ||
            error.code == 'camera_unavailable') {
          setState(() {
            _cameraAvailable = false;
            _message =
                'La cámara no está disponible. Puedes elegir una foto o continuar sin fotografía.';
          });
        } else {
          setState(
            () => _message =
                'No se pudo usar esta función. Revisa los permisos en ajustes o continúa sin ella.',
          );
        }
      }
    } on UnsupportedError {
      if (current()) {
        setState(() {
          if (location) {
            _locationAvailable = false;
          } else if (camera) {
            _cameraAvailable = false;
          }
          _message =
              'Esta función no está disponible en el dispositivo. Puedes continuar sin ella.';
        });
      }
    } catch (_) {
      if (current()) {
        setState(
          () => _message =
              'No se pudo conservar esta información. Puedes reintentar o continuar sin ella.',
        );
      }
    } finally {
      if (!location) {
        await store.endPicker().catchError((Object _) {});
      }
      if (mounted) setState(() => _busy = false);
      if (mounted) widget.onBusyChanged?.call(false);
    }
  }

  Future<void> _removePhoto() async {
    final photo = ref.read(orderDraftProvider).photo;
    final user = ref.read(authControllerProvider).session?.user.id;
    final controller = ref.read(orderDraftProvider.notifier);
    final store = ref.read(evidenceStoreProvider);
    controller.setPhoto(null);
    try {
      await controller.flush();
      if (user != null && photo != null) {
        await store.deleteUnreferencedPhoto(user, photo);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'La foto se quitó del formulario, pero no se pudo eliminar su archivo local.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(orderDraftProvider);
    final storageError = ref.watch(draftStorageErrorProvider);
    final enabled = widget.enabled && !_busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Información opcional del pedido',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Text('Puedes crear el pedido sin fotografía ni ubicación.'),
        const SizedBox(height: 8),
        const Text('Fotografía'),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: enabled && _cameraAvailable
                  ? () => _act(camera: true)
                  : null,
              child: const Text('Tomar foto'),
            ),
            OutlinedButton(
              onPressed: enabled ? () => _act() : null,
              child: const Text('Elegir foto'),
            ),
          ],
        ),
        if (draft.photo != null) ...[
          Image.file(
            File(draft.photo!.path),
            height: 120,
            fit: BoxFit.contain,
            semanticLabel: 'Fotografía opcional del pedido',
            errorBuilder: (_, _, _) => const Text(
              'La foto guardada no está disponible. Puedes quitarla o elegir otra.',
            ),
          ),
          TextButton(
            onPressed: enabled ? _removePhoto : null,
            child: const Text('Quitar foto'),
          ),
        ],
        const Text('Ubicación'),
        OutlinedButton(
          onPressed: enabled && _locationAvailable
              ? () => _act(location: true)
              : null,
          child: const Text('Usar ubicación actual'),
        ),
        if (draft.location != null) ...[
          Text(
            draft.location!.approximate
                ? 'Ubicación agregada · Ubicación aproximada'
                : 'Ubicación agregada',
          ),
          TextButton(
            onPressed: enabled
                ? () => ref.read(orderDraftProvider.notifier).setLocation(null)
                : null,
            child: const Text('Quitar ubicación'),
          ),
        ],
        if (_busy) const LinearProgressIndicator(),
        if (_message != null)
          Semantics(liveRegion: true, child: Text(_message!)),
        if (storageError != null) Text(storageError),
      ],
    );
  }
}
