import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/api_client.dart';
import 'locale_preference.dart';

final localePreferenceRepositoryProvider = Provider<LocalePreferenceRepository>(
  (ref) => LocalePreferenceRepository(ref.watch(dioProvider)),
);

class LocalePreferenceRepository {
  const LocalePreferenceRepository(this._dio);

  final Dio _dio;

  Future<LocalePreference> get() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me/preferences/language',
    );
    return _parse(response.data!);
  }

  Future<LocalePreference> update(LocalePreference preference) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/me/preferences/language',
      data: {'languagePreference': preference.wireValue},
    );
    return _parse(response.data!);
  }

  LocalePreference _parse(Map<String, dynamic> json) {
    return LocalePreference.fromWireValue(
      json['languagePreference'] as String?,
    );
  }
}
