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

  Future<void> requestCode(String mobile) async {
    await _dio.post<void>('/auth/codes', data: {'mobile': mobile});
  }

  Future<AuthSession> login({
    required String mobile,
    required String code,
    required String deviceId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'mobile': mobile, 'code': code, 'deviceId': deviceId},
    );
    return AuthSession.fromJson(response.data!);
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post<void>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }
}
