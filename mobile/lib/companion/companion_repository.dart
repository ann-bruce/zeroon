import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'companion_models.dart';

final companionRepositoryProvider = Provider<CompanionRepository>((ref) {
  return CompanionRepository(ref.watch(dioProvider));
});

class CompanionRepository {
  const CompanionRepository(this._dio);

  final Dio _dio;

  Future<CompanionMessageResponse> sendMessage(
    CompanionMessageRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/companion/messages',
      data: request.toJson(),
    );
    return CompanionMessageResponse.fromJson(response.data!);
  }
}
