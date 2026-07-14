import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'memory_models.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository(ref.watch(dioProvider));
});

class MemoryRepository {
  const MemoryRepository(this._dio);

  final Dio _dio;

  Future<MemoryPage> list({int page = 0, int size = 100}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/memory',
      queryParameters: {'page': page, 'size': size},
    );
    return MemoryPage.fromJson(response.data!);
  }

  Future<MemoryEntry> updateControls(
    int memoryId,
    UpdateMemoryControlsRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/memory/$memoryId',
      data: request.toJson(),
    );
    return MemoryEntry.fromJson(response.data!);
  }

  Future<void> delete(int memoryId) async {
    await _dio.delete<void>('/memory/$memoryId');
  }
}
