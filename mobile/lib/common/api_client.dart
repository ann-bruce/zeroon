import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_models.dart';
import '../auth/token_store.dart';

const zeroonApiBaseUrl = String.fromEnvironment(
  'ZEROON_API_BASE_URL',
  defaultValue: 'http://localhost:8080/api/v1',
);

final dioProvider = Provider<Dio>((ref) {
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
        final session = await ref.read(tokenStoreProvider).read();
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            !_isSessionMutationRequest(error.requestOptions)) {
          final refreshed = await _tryRefresh(ref);
          if (refreshed != null) {
            final retry = await dio.fetch<dynamic>(
              error.requestOptions
                ..headers['Authorization'] = 'Bearer ${refreshed.accessToken}',
            );
            handler.resolve(retry);
            return;
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

bool _isSessionMutationRequest(RequestOptions options) =>
    options.path.endsWith('/auth/refresh') ||
    options.path.endsWith('/auth/logout') ||
    options.path.endsWith('/me/deletion');

Future<AuthSession?> _tryRefresh(Ref ref) async {
  final tokenStore = ref.read(tokenStoreProvider);
  final session = await tokenStore.read();
  if (session == null) {
    return null;
  }

  try {
    final dio = Dio(BaseOptions(baseUrl: zeroonApiBaseUrl));
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': session.refreshToken},
    );
    final refreshed = AuthSession.fromJson(response.data!);
    await tokenStore.save(refreshed);
    return refreshed;
  } catch (_) {
    await tokenStore.clear();
    return null;
  }
}
