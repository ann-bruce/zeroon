import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'state_models.dart';

final stateRepositoryProvider = Provider<StateRepository>((ref) {
  return StateRepository(ref.watch(dioProvider));
});

class StateRepository {
  const StateRepository(this._dio);

  final Dio _dio;

  Future<StateSnapshot> getCurrentState() async {
    final response = await _dio.get<Map<String, dynamic>>('/state/current');
    return StateSnapshot.fromJson(response.data!);
  }

  Future<StateSnapshot> changeState(String state) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/state/sessions',
      data: {'state': state},
    );
    return StateSnapshot.fromJson(response.data!);
  }
}
