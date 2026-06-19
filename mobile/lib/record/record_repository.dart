import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'record_models.dart';

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepository(ref.watch(dioProvider));
});

class RecordRepository {
  const RecordRepository(this._dio);

  final Dio _dio;

  Future<ZeroRecord> create(CreateRecordRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/records',
      data: request.toJson(),
    );
    return ZeroRecord.fromJson(response.data!);
  }

  Future<RecordPage> list({int page = 0, int size = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/records',
      queryParameters: {'page': page, 'size': size},
    );
    return RecordPage.fromJson(response.data!);
  }

  Future<ZeroRecord> get(int recordId) async {
    final response = await _dio.get<Map<String, dynamic>>('/records/$recordId');
    return ZeroRecord.fromJson(response.data!);
  }
}
