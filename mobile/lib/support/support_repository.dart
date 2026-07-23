import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'support_models.dart';

class SupportRepository {
  const SupportRepository(this._dio);

  final Dio _dio;

  Future<SupportReceipt> create(CreateSupportRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/support/requests',
      data: request.toJson(),
    );
    return SupportReceipt.fromJson(response.data!);
  }

  Future<SupportRequestPage> list({int page = 0, int size = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me/support-requests',
      queryParameters: {'page': page, 'size': size},
    );
    return SupportRequestPage.fromJson(response.data!);
  }

  Future<SupportRequestDetail> get(String reference) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me/support-requests/$reference',
    );
    return SupportRequestDetail.fromJson(response.data!);
  }

  Future<SupportMessage> addMessage(String reference, String body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/me/support-requests/$reference/messages',
      data: {'body': body},
    );
    return SupportMessage.fromJson(response.data!);
  }
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(ref.watch(dioProvider));
});
