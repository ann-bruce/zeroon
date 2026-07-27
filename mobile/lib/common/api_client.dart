import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_models.dart';
import '../auth/token_store.dart';
import '../locale/locale_controller.dart';

const zeroonApiBaseUrl = String.fromEnvironment(
  'ZEROON_API_BASE_URL',
  defaultValue: 'http://localhost:8080/api/v1',
);

final dioProvider = Provider<Dio>((ref) {
  ref.watch(accountDataEpochProvider);
  final refreshCoordinator = SessionRefreshCoordinator();
  final dio = Dio(
    BaseOptions(
      baseUrl: zeroonApiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final localeState = ref.read(localeControllerProvider);
        options.headers['Accept-Language'] = localeState
            .effectiveLocale(ref.read(systemLocalesProvider))
            .toLanguageTag();
        final session = await ref.read(tokenStoreProvider).read();
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            error.requestOptions.headers.containsKey('Authorization') &&
            error.requestOptions.extra[_sessionRetryKey] != true &&
            !_isSessionMutationRequest(error.requestOptions)) {
          final refreshed = await refreshCoordinator.run(
            () => _tryRefresh(ref),
          );
          if (refreshed != null) {
            error.requestOptions
              ..headers['Authorization'] = 'Bearer ${refreshed.accessToken}'
              ..extra[_sessionRetryKey] = true;
            try {
              final retry = await dio.fetch<dynamic>(error.requestOptions);
              handler.resolve(retry);
            } on DioException catch (retryError) {
              handler.next(retryError);
            }
            return;
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

const _sessionRetryKey = 'zeroon.session-retried';

bool _isSessionMutationRequest(RequestOptions options) =>
    options.path.contains('/auth/') || options.path.endsWith('/me/deletion');

Future<AuthSession?> _tryRefresh(Ref ref) async {
  final tokenStore = ref.read(tokenStoreProvider);
  final session = await tokenStore.read();
  if (session == null) {
    return null;
  }

  try {
    final localeState = ref.read(localeControllerProvider);
    final dio = Dio(
      BaseOptions(
        baseUrl: zeroonApiBaseUrl,
        headers: {
          'Accept-Language': localeState
              .effectiveLocale(ref.read(systemLocalesProvider))
              .toLanguageTag(),
        },
      ),
    );
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': session.refreshToken},
    );
    final refreshed = AuthSession.fromJson(response.data!);
    await tokenStore.save(refreshed);
    if (!ref.read(localeControllerProvider).pendingAccountSync &&
        refreshed.user.languagePreference != null) {
      await ref
          .read(localeControllerProvider.notifier)
          .adoptAccountPreference(refreshed.user.languagePreference!);
    }
    return refreshed;
  } catch (_) {
    final latest = await tokenStore.read();
    if (latest?.refreshToken == session.refreshToken) {
      final accountEpoch = ref.read(accountDataEpochProvider.notifier);
      final expiryEpoch = ref.read(sessionExpiryEpochProvider.notifier);
      await tokenStore.clear();
      accountEpoch.state += 1;
      expiryEpoch.state += 1;
    }
    return null;
  }
}

class SessionRefreshCoordinator {
  Future<AuthSession?>? _inFlight;

  Future<AuthSession?> run(Future<AuthSession?> Function() refresh) {
    final current = _inFlight;
    if (current != null) {
      return current;
    }

    late final Future<AuthSession?> started;
    started = refresh().whenComplete(() {
      if (identical(_inFlight, started)) {
        _inFlight = null;
      }
    });
    _inFlight = started;
    return started;
  }
}
