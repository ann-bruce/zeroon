import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'growth_models.dart';

final growthRepositoryProvider = Provider<GrowthRepository>((ref) {
  return GrowthRepository(ref.watch(dioProvider));
});

class GrowthRepository {
  const GrowthRepository(this._dio);

  final Dio _dio;

  Future<GrowthSummary> getSummary({String timezone = 'Asia/Shanghai'}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/growth/summary',
      queryParameters: {'timezone': timezone},
    );
    return GrowthSummary.fromJson(response.data!);
  }

  Future<StatePatternSummary> getStatePattern({
    String timezone = 'Asia/Shanghai',
    int days = 14,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/growth/state-pattern',
      queryParameters: {'timezone': timezone, 'days': days},
    );
    return StatePatternSummary.fromJson(response.data!);
  }
}
