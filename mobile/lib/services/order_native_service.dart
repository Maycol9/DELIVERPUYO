import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/order_evidence.dart';

enum NativePermission { granted, denied, permanentlyDenied, restricted }

abstract class OrderNativeService {
  Future<String?> recoverPhoto() async => null;
  Future<NativePermission> cameraPermission({bool request = false});
  Future<NativePermission> locationPermission({bool request = false});
  Future<String?> pickPhoto({required bool camera});
  Future<bool> locationEnabled();
  Future<OrderLocation> currentLocation();
  Future<bool> settings();
}

class PluginOrderNativeService implements OrderNativeService {
  @override
  Future<String?> recoverPhoto() async {
    if (!Platform.isAndroid) return null;
    final data = await ImagePicker().retrieveLostData();
    if (data.exception != null) throw data.exception!;
    return data.files?.firstOrNull?.path;
  }

  bool get supported => Platform.isAndroid || Platform.isIOS;
  NativePermission _state(PermissionStatus status) {
    if (status.isGranted || status.isLimited) return NativePermission.granted;
    if (status.isPermanentlyDenied) return NativePermission.permanentlyDenied;
    if (status.isRestricted) return NativePermission.restricted;
    return NativePermission.denied;
  }

  Future<NativePermission> _permission(
    Permission permission,
    bool request,
  ) async {
    if (!supported) return NativePermission.restricted;
    final status = await permission.status;
    if (request && status.isDenied) return _state(await permission.request());
    return _state(status);
  }

  @override
  Future<NativePermission> cameraPermission({bool request = false}) =>
      _permission(Permission.camera, request);
  @override
  Future<NativePermission> locationPermission({bool request = false}) =>
      _permission(Permission.locationWhenInUse, request);
  @override
  Future<String?> pickPhoto({required bool camera}) async {
    if (!supported) throw UnsupportedError('native');
    final file = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
      requestFullMetadata: false,
    );
    return file?.path;
  }

  @override
  Future<bool> locationEnabled() =>
      supported ? Geolocator.isLocationServiceEnabled() : Future.value(false);
  @override
  Future<OrderLocation> currentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 25),
      ),
    );
    final precision = await Geolocator.getLocationAccuracy();
    return OrderLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      capturedAt: position.timestamp.toUtc().toIso8601String(),
      approximate: precision == LocationAccuracyStatus.reduced,
    );
  }

  @override
  Future<bool> settings() => openAppSettings();
}
