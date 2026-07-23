import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_control/data_control_repository.dart';
import '../locale/locale_controller.dart';
import '../locale/locale_preference.dart';
import '../locale/locale_preference_repository.dart';
import 'auth_models.dart';
import 'auth_repository.dart';
import 'token_store.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final session = await ref.watch(tokenStoreProvider).read();
    if (session != null) {
      await _synchronizeLocaleFromSession(session);
    }
    return session;
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
      await _synchronizeLocaleFromSession(session);
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

  Future<void> selectLanguagePreference(LocalePreference preference) async {
    Object? storageFailure;
    try {
      await ref
          .read(localeControllerProvider.notifier)
          .selectDevicePreference(preference);
    } catch (error) {
      storageFailure = error;
    }

    final session =
        state.valueOrNull ?? await ref.read(tokenStoreProvider).read();
    if (session != null) {
      await _pushPendingLocale(session);
    }
    if (storageFailure != null) {
      throw storageFailure;
    }
  }

  Future<void> _synchronizeLocaleFromSession(AuthSession session) async {
    final localeState = ref.read(localeControllerProvider);
    if (localeState.pendingAccountSync) {
      unawaited(_pushPendingLocale(session));
      return;
    }

    final accountPreference = session.user.languagePreference;
    if (accountPreference != null) {
      await ref
          .read(localeControllerProvider.notifier)
          .adoptAccountPreference(accountPreference);
    }
  }

  Future<void> _pushPendingLocale(AuthSession session) async {
    final snapshot = ref.read(localeControllerProvider);
    if (!snapshot.pendingAccountSync) {
      return;
    }
    final requestedPreference = snapshot.preference;

    try {
      final savedPreference = await ref
          .read(localePreferenceRepositoryProvider)
          .update(requestedPreference);
      if (savedPreference != requestedPreference) {
        return;
      }
      final confirmed = await ref
          .read(localeControllerProvider.notifier)
          .confirmAccountPreference(savedPreference);
      if (!confirmed) {
        final latestSession = state.valueOrNull ?? session;
        unawaited(_pushPendingLocale(latestSession));
        return;
      }

      final updatedSession = session.copyWith(
        user: session.user.copyWith(languagePreference: savedPreference),
      );
      await ref.read(tokenStoreProvider).save(updatedSession);
      final currentSession = state.valueOrNull;
      if (currentSession != null &&
          currentSession.refreshToken == session.refreshToken) {
        state = AsyncData(updatedSession);
      }
    } catch (_) {
      // The local choice remains active and pending for the next safe retry.
    }
  }
}
