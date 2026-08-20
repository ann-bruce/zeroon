import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/token_store.dart';

final resetDraftStoreProvider = Provider<ResetDraftStore>((ref) {
  return SecureResetDraftStore(ref.watch(secureStorageProvider));
});

class ResetDraft {
  const ResetDraft({
    required this.intentKey,
    required this.content,
    required this.goal,
    required this.showSmallDirection,
    this.stateSessionId,
  });

  final String intentKey;
  final String content;
  final String goal;
  final bool showSmallDirection;
  final int? stateSessionId;

  bool get hasInput =>
      content.isNotEmpty || goal.isNotEmpty || showSmallDirection;

  factory ResetDraft.fromJson(Map<String, dynamic> json) {
    return ResetDraft(
      intentKey: json['intentKey'] as String,
      content: json['content'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      showSmallDirection: json['showSmallDirection'] as bool? ?? false,
      stateSessionId: json['stateSessionId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'intentKey': intentKey,
        'content': content,
        'goal': goal,
        'showSmallDirection': showSmallDirection,
        if (stateSessionId != null) 'stateSessionId': stateSessionId,
      };
}

abstract interface class ResetDraftStore {
  Future<ResetDraft?> read(String ownerUid);

  Future<void> write(String ownerUid, ResetDraft draft);

  Future<void> clear(String ownerUid);
}

class SecureResetDraftStore implements ResetDraftStore {
  const SecureResetDraftStore(this._storage);

  static const _prefix = 'zeroon.reset-draft.';
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage;

  @override
  Future<ResetDraft?> read(String ownerUid) async {
    final raw = await _storage.read(
      key: _key(ownerUid),
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
    if (raw == null) {
      return null;
    }
    try {
      return ResetDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      await clear(ownerUid);
      return null;
    } on TypeError {
      await clear(ownerUid);
      return null;
    }
  }

  @override
  Future<void> write(String ownerUid, ResetDraft draft) {
    return _storage.write(
      key: _key(ownerUid),
      value: jsonEncode(draft.toJson()),
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  @override
  Future<void> clear(String ownerUid) {
    return _storage.delete(
      key: _key(ownerUid),
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  String _key(String ownerUid) {
    final encoded = base64Url.encode(utf8.encode(ownerUid)).replaceAll('=', '');
    return '$_prefix$encoded';
  }
}
