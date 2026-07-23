import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_preference.dart';
import 'locale_preference_store.dart';

class LocaleState {
  const LocaleState({
    required this.preference,
    required this.pendingAccountSync,
    required this.deviceStorageAvailable,
  });

  const LocaleState.followSystem()
      : preference = LocalePreference.followSystem,
        pendingAccountSync = false,
        deviceStorageAvailable = true;

  final LocalePreference preference;
  final bool pendingAccountSync;
  final bool deviceStorageAvailable;

  Locale? get materialLocale => preference.materialLocale;

  Locale effectiveLocale(List<Locale>? systemLocales) {
    return preference.effectiveLocale(systemLocales);
  }

  LocaleState copyWith({
    LocalePreference? preference,
    bool? pendingAccountSync,
    bool? deviceStorageAvailable,
  }) {
    return LocaleState(
      preference: preference ?? this.preference,
      pendingAccountSync: pendingAccountSync ?? this.pendingAccountSync,
      deviceStorageAvailable:
          deviceStorageAvailable ?? this.deviceStorageAvailable,
    );
  }
}

class LocaleBootstrap {
  const LocaleBootstrap({required this.store, required this.state});

  final LocalePreferenceStore store;
  final LocaleState state;
}

Future<LocaleBootstrap> bootstrapLocale() async {
  try {
    final store = await SharedPreferencesLocalePreferenceStore.create();
    try {
      final stored = await store.read();
      return LocaleBootstrap(
        store: store,
        state: LocaleState(
          preference: stored.preference,
          pendingAccountSync: stored.pendingAccountSync,
          deviceStorageAvailable: true,
        ),
      );
    } catch (_) {
      return LocaleBootstrap(
        store: store,
        state: const LocaleState(
          preference: LocalePreference.followSystem,
          pendingAccountSync: false,
          deviceStorageAvailable: false,
        ),
      );
    }
  } catch (_) {
    return LocaleBootstrap(
      store: VolatileLocalePreferenceStore(),
      state: const LocaleState(
        preference: LocalePreference.followSystem,
        pendingAccountSync: false,
        deviceStorageAvailable: false,
      ),
    );
  }
}

final initialLocaleStateProvider = Provider<LocaleState>((ref) {
  return const LocaleState.followSystem();
});

final localePreferenceStoreProvider = Provider<LocalePreferenceStore>((ref) {
  return VolatileLocalePreferenceStore();
});

final systemLocalesProvider = Provider<List<Locale>>((ref) {
  return WidgetsBinding.instance.platformDispatcher.locales;
});

final localeControllerProvider =
    NotifierProvider<LocaleController, LocaleState>(LocaleController.new);

class LocaleController extends Notifier<LocaleState> {
  @override
  LocaleState build() => ref.watch(initialLocaleStateProvider);

  Future<void> selectDevicePreference(LocalePreference preference) async {
    state = LocaleState(
      preference: preference,
      pendingAccountSync: true,
      deviceStorageAvailable: state.deviceStorageAvailable,
    );

    try {
      await ref.read(localePreferenceStoreProvider).write(
            StoredLocalePreference(
              preference: preference,
              pendingAccountSync: true,
            ),
          );
    } catch (_) {
      state = state.copyWith(deviceStorageAvailable: false);
      rethrow;
    }
  }

  Future<void> adoptAccountPreference(LocalePreference preference) async {
    if (state.pendingAccountSync) {
      return;
    }
    state = LocaleState(
      preference: preference,
      pendingAccountSync: false,
      deviceStorageAvailable: state.deviceStorageAvailable,
    );
    await _persistSynchronized(preference);
  }

  Future<bool> confirmAccountPreference(LocalePreference preference) async {
    if (!state.pendingAccountSync || state.preference != preference) {
      return false;
    }
    state = state.copyWith(pendingAccountSync: false);
    await _persistSynchronized(preference);
    return true;
  }

  Future<void> _persistSynchronized(LocalePreference preference) async {
    try {
      await ref.read(localePreferenceStoreProvider).write(
            StoredLocalePreference(
              preference: preference,
              pendingAccountSync: false,
            ),
          );
    } catch (_) {
      state = state.copyWith(deviceStorageAvailable: false);
    }
  }
}
