import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_models.dart';
import 'auth_repository.dart';
import 'token_store.dart';

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
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(null);
  }

  void replaceSession(AuthSession? session) {
    state = AsyncData(session);
  }
}
