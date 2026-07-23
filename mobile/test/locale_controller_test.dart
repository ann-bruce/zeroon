import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeroon_mobile/auth/auth_models.dart';
import 'package:zeroon_mobile/auth/token_store.dart';
import 'package:zeroon_mobile/l10n/app_localizations.dart';
import 'package:zeroon_mobile/locale/locale_controller.dart';
import 'package:zeroon_mobile/locale/locale_preference.dart';
import 'package:zeroon_mobile/locale/locale_preference_store.dart';
import 'package:zeroon_mobile/main.dart';

void main() {
  group('LocalePreference', () {
    test('uses stable wire values and safely repairs malformed values', () {
      expect(
        LocalePreference.fromWireValue('FOLLOW_SYSTEM'),
        LocalePreference.followSystem,
      );
      expect(
        LocalePreference.fromWireValue('ZH_CN'),
        LocalePreference.simplifiedChinese,
      );
      expect(LocalePreference.fromWireValue('EN'), LocalePreference.english);
      expect(
        LocalePreference.fromWireValue('zh-CN'),
        LocalePreference.followSystem,
      );
      expect(
        LocalePreference.fromWireValue(null),
        LocalePreference.followSystem,
      );
    });

    test('resolves explicit and system preferences deterministically', () {
      expect(
        resolveEffectiveLocale(LocalePreference.english, const [
          Locale('zh', 'CN'),
        ]),
        englishLocale,
      );
      expect(
        resolveEffectiveLocale(LocalePreference.simplifiedChinese, const [
          Locale('en'),
        ]),
        simplifiedChineseLocale,
      );
      expect(
        resolveEffectiveLocale(LocalePreference.followSystem, const [
          Locale('en', 'US'),
        ]),
        englishLocale,
      );
      expect(
        resolveEffectiveLocale(LocalePreference.followSystem, const [
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ]),
        simplifiedChineseLocale,
      );
      expect(
        resolveEffectiveLocale(LocalePreference.followSystem, const [
          Locale('fr', 'FR'),
        ]),
        simplifiedChineseLocale,
      );
      expect(
        resolveEffectiveLocale(LocalePreference.followSystem, const []),
        simplifiedChineseLocale,
      );
    });
  });

  group('SharedPreferencesLocalePreferenceStore', () {
    test('defaults to Follow System and persists explicit device state',
        () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SharedPreferencesLocalePreferenceStore.create();

      final initial = await store.read();
      expect(initial.preference, LocalePreference.followSystem);
      expect(initial.pendingAccountSync, isFalse);

      await store.write(
        const StoredLocalePreference(
          preference: LocalePreference.english,
          pendingAccountSync: true,
        ),
      );

      final restored = await store.read();
      expect(restored.preference, LocalePreference.english);
      expect(restored.pendingAccountSync, isTrue);
    });

    test('falls back safely when the stored enum is malformed', () async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesLocalePreferenceStore.stateKey:
            '{"preference":"UNKNOWN","pendingAccountSync":true}',
      });
      final store = await SharedPreferencesLocalePreferenceStore.create();

      final restored = await store.read();

      expect(restored.preference, LocalePreference.followSystem);
      expect(restored.pendingAccountSync, isTrue);
    });

    test('falls back safely when the stored state is not valid JSON', () async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesLocalePreferenceStore.stateKey: 'not-json',
      });
      final store = await SharedPreferencesLocalePreferenceStore.create();

      final restored = await store.read();

      expect(restored.preference, LocalePreference.followSystem);
      expect(restored.pendingAccountSync, isFalse);
    });
  });

  group('LocaleController', () {
    test('switches immediately and then persists a pending account value',
        () async {
      final store = _DelayedLocalePreferenceStore();
      final container = ProviderContainer(
        overrides: [
          localePreferenceStoreProvider.overrideWithValue(store),
          initialLocaleStateProvider.overrideWithValue(
            const LocaleState.followSystem(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final write = container
          .read(localeControllerProvider.notifier)
          .selectDevicePreference(LocalePreference.english);

      final immediate = container.read(localeControllerProvider);
      expect(immediate.preference, LocalePreference.english);
      expect(immediate.pendingAccountSync, isTrue);
      expect(immediate.deviceStorageAvailable, isTrue);

      store.completeWrite();
      await write;
      expect(store.written?.preference, LocalePreference.english);
      expect(store.written?.pendingAccountSync, isTrue);
    });

    test('keeps the selected locale when device persistence fails', () async {
      final container = ProviderContainer(
        overrides: [
          localePreferenceStoreProvider.overrideWithValue(
            _FailingLocalePreferenceStore(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(localeControllerProvider.notifier)
            .selectDevicePreference(LocalePreference.english),
        throwsStateError,
      );

      final state = container.read(localeControllerProvider);
      expect(state.preference, LocalePreference.english);
      expect(state.pendingAccountSync, isTrue);
      expect(state.deviceStorageAvailable, isFalse);
    });

    test('does not let stale account responses replace a newer device choice',
        () async {
      final container = ProviderContainer(
        overrides: [
          initialLocaleStateProvider.overrideWithValue(
            const LocaleState(
              preference: LocalePreference.simplifiedChinese,
              pendingAccountSync: true,
              deviceStorageAvailable: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(localeControllerProvider.notifier);

      await controller.adoptAccountPreference(LocalePreference.english);
      final confirmed = await controller.confirmAccountPreference(
        LocalePreference.english,
      );

      expect(confirmed, isFalse);
      final state = container.read(localeControllerProvider);
      expect(state.preference, LocalePreference.simplifiedChinese);
      expect(state.pendingAccountSync, isTrue);
    });
  });

  testWidgets('restored English is active on the first localized app frame', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesLocalePreferenceStore.stateKey:
          '{"preference":"EN","pendingAccountSync":false}',
    });
    final bootstrap = await bootstrapLocale();
    expect(bootstrap.state.preference, LocalePreference.english);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocaleStateProvider.overrideWithValue(bootstrap.state),
          localePreferenceStoreProvider.overrideWithValue(bootstrap.store),
          tokenStoreProvider.overrideWithValue(_EmptyTokenStore()),
        ],
        child: const ZeroonApp(),
      ),
    );

    final firstLocalizedSurface = tester.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(firstLocalizedSurface), englishLocale);
    expect(
      AppLocalizations.of(firstLocalizedSurface).languageFollowSystem,
      'Follow system',
    );

    await tester.pumpAndSettle();
    final settledSurface = tester.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(settledSurface), englishLocale);
  });
}

class _DelayedLocalePreferenceStore implements LocalePreferenceStore {
  final Completer<void> _writeCompleter = Completer<void>();
  StoredLocalePreference? written;

  @override
  Future<StoredLocalePreference> read() async {
    return const StoredLocalePreference.followSystem();
  }

  @override
  Future<void> write(StoredLocalePreference value) {
    written = value;
    return _writeCompleter.future;
  }

  void completeWrite() => _writeCompleter.complete();
}

class _FailingLocalePreferenceStore implements LocalePreferenceStore {
  @override
  Future<StoredLocalePreference> read() async {
    return const StoredLocalePreference.followSystem();
  }

  @override
  Future<void> write(StoredLocalePreference value) {
    throw StateError('storage unavailable');
  }
}

class _EmptyTokenStore implements TokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> save(AuthSession session) async {}
}
