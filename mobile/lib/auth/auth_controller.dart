import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_models.dart';
import 'auth_repository.dart';
import 'token_store.dart';
import '../data_control/data_control_repository.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() {
    return ref.watch(tokenStoreProvider).read();
  }

  Future<void> requestCode(String mobile) {
    return ref.read(authRepositoryProvider).requestCode(mobile);
  }

  Future<void> login({
    required String mobile,
    required String code,
    required String deviceId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(mobile: mobile, code: code, deviceId: deviceId);
      await ref.read(tokenStoreProvider).save(session);
      return session;
    });
  }

  Future<void> logout() async {
    final tokenStore = ref.read(tokenStoreProvider);
    final session = state.valueOrNull ?? await tokenStore.read();
    try {
      if (session != null) {
        await ref.read(authRepositoryProvider).logout(session.refreshToken);
      }
    } catch (_) {
      // Local exit must remain available when remote session revocation fails.
    } finally {
      await tokenStore.clear();
      state = const AsyncData(null);
    }
  }

  Future<void> deleteAccount() async {
    await ref.read(dataControlRepositoryProvider).deleteAccount();
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(null);
  }

  void replaceSession(AuthSession? session) {
    state = AsyncData(session);
  }
}
