import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  Future<void> requestEmailCode(String email) async {
    await _dio.post<void>('/auth/email/codes', data: {'email': email});
  }

  Future<AuthSession> login({
    required String email,
    required String code,
    required String deviceId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/email/login',
      data: {'email': email, 'code': code, 'deviceId': deviceId},
    );
    return AuthSession.fromJson(response.data!)
        .copyWith(freshAuthentication: true);
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post<void>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }
}
