import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'my_zeroon_models.dart';

final myZeroonRepositoryProvider = Provider<MyZeroonRepository>((ref) {
  return MyZeroonRepository(ref.watch(dioProvider));
});

class MyZeroonRepository {
  const MyZeroonRepository(this._dio);

  final Dio _dio;

  Future<MyZeroonCompanion> get() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/me/zeroon-companion');
    return MyZeroonCompanion.fromJson(response.data!);
  }

  Future<MyZeroonCompanion> meet([
    MeetMyZeroonRequest request = const MeetMyZeroonRequest(),
  ]) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/me/zeroon-companion',
      data: request.toJson(),
    );
    return MyZeroonCompanion.fromJson(response.data!);
  }
}
