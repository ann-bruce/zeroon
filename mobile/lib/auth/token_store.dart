import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_models.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return SecureTokenStore(ref.watch(secureStorageProvider));
});

/// Changes whenever the active account changes or becomes invalid.
///
/// API-backed repositories indirectly depend on this epoch through the shared
/// API client, so private cached state is rebuilt before another account enters
/// the authenticated UI.
final accountDataEpochProvider = StateProvider<int>((ref) => 0);

/// Notifies the authentication controller that credentials were invalidated
/// outside an explicit login/logout action, for example after a terminal
/// refresh failure.
final sessionExpiryEpochProvider = StateProvider<int>((ref) => 0);

abstract interface class TokenStore {
  Future<AuthSession?> read();

  Future<void> save(AuthSession session);

  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  const SecureTokenStore(this._storage);

  static const _sessionKey = 'zeroon.auth.session';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> read() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null) {
      return null;
    }
    return AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(AuthSession session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  @override
  Future<void> clear() {
    return _storage.delete(key: _sessionKey);
  }
}
