import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

final deviceIdStoreProvider = Provider<DeviceIdStore>((ref) {
  return SecureDeviceIdStore(ref.watch(secureStorageProvider));
});

abstract interface class DeviceIdStore {
  Future<String> readOrCreate();
}

class SecureDeviceIdStore implements DeviceIdStore {
  const SecureDeviceIdStore(this._storage);

  static const _deviceIdKey = 'zeroon.auth.device-id';

  final FlutterSecureStorage _storage;

  @override
  Future<String> readOrCreate() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.length >= 8 && existing.length <= 128) {
      return existing;
    }
    final created = 'zeroon-${_uuidV4()}';
    await _storage.write(key: _deviceIdKey, value: created);
    return created;
  }
}

String _uuidV4() {
  final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex =
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}
