import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';

final dataControlRepositoryProvider = Provider<DataControlRepository>((ref) {
  return DataControlRepository(ref.watch(dioProvider));
});

class DataControlRepository {
  const DataControlRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> exportData() async {
    final response = await _dio.get<Map<String, dynamic>>('/me/export');
    return response.data!;
  }

  Future<void> deleteAccount() async {
    await _dio.delete<void>('/me/deletion');
  }
}
