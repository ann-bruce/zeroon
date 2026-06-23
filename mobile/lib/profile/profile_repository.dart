import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

class ProfileRepository {
  const ProfileRepository(this._dio);

  final Dio _dio;

  Future<UserProfile> get() async {
    final response = await _dio.get<Map<String, dynamic>>('/me/profile');
    return UserProfile.fromJson(response.data!);
  }

  Future<UserProfile> update(UpdateUserProfileRequest request) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/me/profile',
      data: request.toJson(),
    );
    return UserProfile.fromJson(response.data!);
  }
}
