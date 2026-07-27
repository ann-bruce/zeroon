import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/auth/auth_models.dart';
import 'package:zeroon_mobile/auth/token_store.dart';
import 'package:zeroon_mobile/common/api_client.dart';

void main() {
  test('concurrent unauthorized requests share one token refresh', () async {
    final coordinator = SessionRefreshCoordinator();
    final completer = Completer<AuthSession?>();
    var refreshCalls = 0;

    Future<AuthSession?> refresh() {
      refreshCalls += 1;
      return completer.future;
    }

    final first = coordinator.run(refresh);
    final second = coordinator.run(refresh);

    expect(refreshCalls, 1);
    expect(identical(first, second), isTrue);

    completer.complete(_session);
    expect(await first, _session);
    expect(await second, _session);
  });

  test('a completed refresh does not block the next refresh', () async {
    final coordinator = SessionRefreshCoordinator();
    var refreshCalls = 0;

    Future<AuthSession?> refresh() async {
      refreshCalls += 1;
      return _session;
    }

    await coordinator.run(refresh);
    await coordinator.run(refresh);

    expect(refreshCalls, 2);
  });

  test('changing accounts rebuilds the shared API client', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final first = container.read(dioProvider);
    container.read(accountDataEpochProvider.notifier).state += 1;
    final second = container.read(dioProvider);

    expect(identical(first, second), isFalse);
  });
}

const _session = AuthSession(
  accessToken: 'new-access-token',
  refreshToken: 'new-refresh-token',
  expiresIn: 1800,
  user: ZeroonUser(
    uid: 'u-refresh-test',
    mobile: null,
    currentState: 'CALM',
  ),
);
