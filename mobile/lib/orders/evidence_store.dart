import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../models/order.dart';
import '../models/order_evidence.dart';

/// Files and metadata are private and namespaced by authenticated account.
/// Logout retains offline work for that same account; it is never loaded for another.
class EvidenceStore {
  EvidenceStore({Future<Directory> Function()? directory})
    : directory = directory ?? getApplicationSupportDirectory;
  final Future<Directory> Function() directory;
  static const storage = FlutterSecureStorage();
  String _owner(String user) =>
      base64Url.encode(utf8.encode(user)).replaceAll('=', '');
  String key(String user) => 'deliverpuyo.draft.v14.${_owner(user)}';
  Future<void> beginPicker(String user) =>
      storage.write(key: 'deliverpuyo.picker.owner.v14', value: user);
  Future<bool> hasPendingPicker(String user) async =>
      await storage.read(key: 'deliverpuyo.picker.owner.v14') == user;
  Future<void> endPicker() =>
      storage.delete(key: 'deliverpuyo.picker.owner.v14');

  Future<Directory> _folder(String user) async =>
      Directory('${(await directory()).path}/order_evidence/${_owner(user)}');

  Future<OrderPhoto> importPhoto(String user, String source) async {
    final folder = await _folder(user);
    await folder.create(recursive: true);
    final stamp = DateTime.now().toUtc();
    final name =
        '${stamp.microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}.jpg';
    final target = '${folder.path}/$name';
    await File(source).copy(target);
    return OrderPhoto(path: target, capturedAt: stamp.toIso8601String());
  }

  Future<void> deletePhoto(String user, OrderPhoto photo) async {
    final folder = await _folder(user);
    final file = File(photo.path);
    if (file.parent.absolute.path != folder.absolute.path) return;
    if (await file.exists()) await file.delete();
  }

  Future<void> deleteUnreferencedPhoto(String user, OrderPhoto photo) async {
    final values = await storage.readAll();
    final referenced = values.entries
        .where(
          (entry) =>
              entry.key == key(user) ||
              entry.key == 'deliverpuyo.outbox.v1.$user' ||
              entry.key.startsWith('deliverpuyo.evidence.v14.${_owner(user)}.'),
        )
        .any((entry) => entry.value.contains(jsonEncode(photo.path)));
    if (!referenced) await deletePhoto(user, photo);
  }

  Future<OrderDraft?> readDraft(String user) async {
    final value = await storage.read(key: key(user));
    return value == null
        ? null
        : OrderDraft.fromLocalJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> saveDraft(String user, OrderDraft draft) => draft.isEmpty
      ? storage.delete(key: key(user))
      : storage.write(key: key(user), value: jsonEncode(draft.toLocalJson()));

  Future<void> archive(String user, String orderId, OrderDraft draft) async {
    if (draft.photo == null && draft.location == null) return;
    await storage.write(
      key: 'deliverpuyo.evidence.v14.${_owner(user)}.$orderId',
      value: jsonEncode({'orderId': orderId, ...draft.toLocalJson()}),
    );
  }
}
