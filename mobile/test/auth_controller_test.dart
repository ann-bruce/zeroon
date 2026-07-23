import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/auth/auth_controller.dart';
import 'package:zeroon_mobile/auth/auth_models.dart';
import 'package:zeroon_mobile/auth/auth_repository.dart';
import 'package:zeroon_mobile/auth/token_store.dart';
import 'package:zeroon_mobile/data_control/data_control_repository.dart';
import 'package:zeroon_mobile/evidence/evidence_models.dart';
import 'package:zeroon_mobile/evidence/evidence_repository.dart';
import 'package:zeroon_mobile/locale/locale_controller.dart';
import 'package:zeroon_mobile/locale/locale_preference.dart';
import 'package:zeroon_mobile/locale/locale_preference_repository.dart';
import 'package:zeroon_mobile/locale/locale_preference_store.dart';

void main() {
  test('logout revokes the remote session and clears local credentials',
      () async {
    final tokenStore = _MemoryTokenStore(_session);
    final authRepository = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        evidenceRepositoryProvider.overrideWithValue(_NoopEvidenceRepository()),
        tokenStoreProvider.overrideWithValue(tokenStore),
        authRepositoryProvider.overrideWithValue(authRepository),
        initialLocaleStateProvider.overrideWithValue(
          const LocaleState(
            preference: LocalePreference.english,
            pendingAccountSync: false,
            deviceStorageAvailable: true,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);
    expect(
      container.read(localeControllerProvider).preference,
      LocalePreference.english,
    );

    await container.read(authControllerProvider.notifier).logout();

    expect(authRepository.loggedOutRefreshToken, 'refresh-token');
    expect(await tokenStore.read(), isNull);
    expect(container.read(authControllerProvider).valueOrNull, isNull);
    expect(
      container.read(localeControllerProvider).preference,
      LocalePreference.english,
    );
  });

  test('logout still clears local credentials when remote revocation fails',
      () async {
    final tokenStore = _MemoryTokenStore(_session);
    final authRepository = _FakeAuthRepository(failLogout: true);
    final container = ProviderContainer(
      overrides: [
        evidenceRepositoryProvider.overrideWithValue(_NoopEvidenceRepository()),
        tokenStoreProvider.overrideWithValue(tokenStore),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).logout();

    expect(await tokenStore.read(), isNull);
    expect(container.read(authControllerProvider).valueOrNull, isNull);
  });

  test('successful account deletion clears the local session', () async {
    final tokenStore = _MemoryTokenStore(_session);
    final dataControlRepository = _FakeDataControlRepository();
    final container = ProviderContainer(
      overrides: [
        evidenceRepositoryProvider.overrideWithValue(_NoopEvidenceRepository()),
        tokenStoreProvider.overrideWithValue(tokenStore),
        dataControlRepositoryProvider.overrideWithValue(dataControlRepository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).deleteAccount();

    expect(dataControlRepository.deleted, isTrue);
    expect(await tokenStore.read(), isNull);
    expect(container.read(authControllerProvider).valueOrNull, isNull);
  });

  test('account preference wins when the device has no pending choice',
      () async {
    final tokenStore = _MemoryTokenStore(
      _sessionWithPreference(LocalePreference.english),
    );
    final localeStore = _MemoryLocalePreferenceStore();
    final container = ProviderContainer(
      overrides: [
        evidenceRepositoryProvider.overrideWithValue(_NoopEvidenceRepository()),
        tokenStoreProvider.overrideWithValue(tokenStore),
        localePreferenceStoreProvider.overrideWithValue(localeStore),
        initialLocaleStateProvider.overrideWithValue(
          const LocaleState(
            preference: LocalePreference.simplifiedChinese,
            pendingAccountSync: false,
            deviceStorageAvailable: true,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);

    final locale = container.read(localeControllerProvider);
    expect(locale.preference, LocalePreference.english);
    expect(locale.pendingAccountSync, isFalse);
    expect(localeStore.value?.preference, LocalePreference.english);
    expect(localeStore.value?.pendingAccountSync, isFalse);
  });

  test('pending device choice wins once and updates the cached account',
      () async {
    final tokenStore = _MemoryTokenStore(null);
    final authRepository = _FakeAuthRepository(
      loginSession: _sessionWithPreference(LocalePreference.followSystem),
    );
    final localeRepository = _FakeLocalePreferenceRepository();
    final localeStore = _MemoryLocalePreferenceStore();
    final container = ProviderContainer(
      overrides: [
        evidenceRepositoryProvider.overrideWithValue(_NoopEvidenceRepository()),
        tokenStoreProvider.overrideWithValue(tokenStore),
        authRepositoryProvider.overrideWithValue(authRepository),
        localePreferenceRepositoryProvider.overrideWithValue(localeRepository),
        localePreferenceStoreProvider.overrideWithValue(localeStore),
        initialLocaleStateProvider.overrideWithValue(
          const LocaleState(
            preference: LocalePreference.english,
            pendingAccountSync: true,
            deviceStorageAvailable: true,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).login(
          mobile: '13800138000',
          code: '000000',
          deviceId: 'language-device',
        );
    await pumpEventQueue(times: 10);

    expect(localeRepository.updated, [LocalePreference.english]);
    expect(
        container.read(localeControllerProvider).pendingAccountSync, isFalse);
    expect(localeStore.value?.pendingAccountSync, isFalse);
    expect(
      (await tokenStore.read())?.user.languagePreference,
      LocalePreference.english,
    );
  });
}

const _session = AuthSession(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  expiresIn: 1800,
  user: ZeroonUser(
    uid: 'u-data-control-test',
    mobile: '13800138000',
    currentState: 'CALM',
  ),
);

class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore(this.session);

  AuthSession? session;

  @override
  Future<void> clear() async => session = null;

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> save(AuthSession value) async => session = value;
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.failLogout = false, this.loginSession})
      : super(Dio());

  final bool failLogout;
  final AuthSession? loginSession;
  String? loggedOutRefreshToken;

  @override
  Future<AuthSession> login({
    required String mobile,
    required String code,
    required String deviceId,
  }) async {
    return loginSession ?? _session;
  }

  @override
  Future<void> logout(String refreshToken) async {
    loggedOutRefreshToken = refreshToken;
    if (failLogout) {
      throw StateError('remote unavailable');
    }
  }
}

class _FakeDataControlRepository extends DataControlRepository {
  _FakeDataControlRepository() : super(Dio());

  bool deleted = false;

  @override
  Future<void> deleteAccount() async {
    deleted = true;
  }
}

AuthSession _sessionWithPreference(LocalePreference preference) {
  return AuthSession(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    expiresIn: 1800,
    user: ZeroonUser(
      uid: 'u-data-control-test',
      mobile: '13800138000',
      currentState: 'CALM',
      languagePreference: preference,
    ),
  );
}

class _MemoryLocalePreferenceStore implements LocalePreferenceStore {
  StoredLocalePreference? value;

  @override
  Future<StoredLocalePreference> read() async {
    return value ?? const StoredLocalePreference.followSystem();
  }

  @override
  Future<void> write(StoredLocalePreference next) async {
    value = next;
  }
}

class _FakeLocalePreferenceRepository extends LocalePreferenceRepository {
  _FakeLocalePreferenceRepository() : super(Dio());

  final List<LocalePreference> updated = [];

  @override
  Future<LocalePreference> update(LocalePreference preference) async {
    updated.add(preference);
    return preference;
  }
}

class _NoopEvidenceRepository extends EvidenceRepository {
  _NoopEvidenceRepository() : super(Dio());

  @override
  Future<void> record(EvidenceEvent event) async {}
}
