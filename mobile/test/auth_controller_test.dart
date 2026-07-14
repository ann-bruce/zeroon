import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/auth/auth_controller.dart';
import 'package:zeroon_mobile/auth/auth_models.dart';
import 'package:zeroon_mobile/auth/auth_repository.dart';
import 'package:zeroon_mobile/auth/token_store.dart';
import 'package:zeroon_mobile/data_control/data_control_repository.dart';

void main() {
  test('logout revokes the remote session and clears local credentials', () async {
    final tokenStore = _MemoryTokenStore(_session);
    final authRepository = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(tokenStore),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).logout();

    expect(authRepository.loggedOutRefreshToken, 'refresh-token');
    expect(await tokenStore.read(), isNull);
    expect(container.read(authControllerProvider).valueOrNull, isNull);
  });

  test('logout still clears local credentials when remote revocation fails', () async {
    final tokenStore = _MemoryTokenStore(_session);
    final authRepository = _FakeAuthRepository(failLogout: true);
    final container = ProviderContainer(
      overrides: [
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
  _FakeAuthRepository({this.failLogout = false}) : super(Dio());

  final bool failLogout;
  String? loggedOutRefreshToken;

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
