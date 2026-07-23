import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'locale_preference.dart';

class StoredLocalePreference {
  const StoredLocalePreference({
    required this.preference,
    required this.pendingAccountSync,
  });

  const StoredLocalePreference.followSystem()
      : preference = LocalePreference.followSystem,
        pendingAccountSync = false;

  final LocalePreference preference;
  final bool pendingAccountSync;
}

abstract interface class LocalePreferenceStore {
  Future<StoredLocalePreference> read();

  Future<void> write(StoredLocalePreference value);
}

class SharedPreferencesLocalePreferenceStore implements LocalePreferenceStore {
  const SharedPreferencesLocalePreferenceStore(this._preferences);

  static const stateKey = 'zeroon.locale.state';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesLocalePreferenceStore> create() async {
    return SharedPreferencesLocalePreferenceStore(
      await SharedPreferences.getInstance(),
    );
  }

  @override
  Future<StoredLocalePreference> read() async {
    final rawState = _preferences.getString(stateKey);
    if (rawState == null) {
      return const StoredLocalePreference.followSystem();
    }
    try {
      final decoded = jsonDecode(rawState);
      if (decoded is! Map<String, dynamic>) {
        return const StoredLocalePreference.followSystem();
      }
      return StoredLocalePreference(
        preference: LocalePreference.fromWireValue(
          decoded['preference'] as String?,
        ),
        pendingAccountSync: decoded['pendingAccountSync'] == true,
      );
    } catch (_) {
      return const StoredLocalePreference.followSystem();
    }
  }

  @override
  Future<void> write(StoredLocalePreference value) async {
    final saved = await _preferences.setString(
      stateKey,
      jsonEncode({
        'preference': value.preference.wireValue,
        'pendingAccountSync': value.pendingAccountSync,
      }),
    );
    if (!saved) {
      throw StateError('Locale preference storage rejected the write');
    }
  }
}

class VolatileLocalePreferenceStore implements LocalePreferenceStore {
  StoredLocalePreference _value = const StoredLocalePreference.followSystem();

  @override
  Future<StoredLocalePreference> read() async => _value;

  @override
  Future<void> write(StoredLocalePreference value) async {
    _value = value;
  }
}
