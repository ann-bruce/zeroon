import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/auth/auth_models.dart';
import 'package:zeroon_mobile/auth/token_store.dart';
import 'package:zeroon_mobile/common/api_client.dart';
import 'package:zeroon_mobile/locale/locale_controller.dart';
import 'package:zeroon_mobile/locale/locale_preference.dart';
import 'package:zeroon_mobile/locale/locale_preference_repository.dart';

void main() {
  test('updates the account preference with the resolved language header',
      () async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_EmptyTokenStore()),
        initialLocaleStateProvider.overrideWithValue(
          const LocaleState(
            preference: LocalePreference.english,
            pendingAccountSync: true,
            deviceStorageAvailable: true,
          ),
        ),
        systemLocalesProvider.overrideWithValue(const [Locale('zh', 'CN')]),
      ],
    );
    addTearDown(container.dispose);
    final dio = container.read(dioProvider);
    final adapter = _CapturingAdapter(
      '{"languagePreference":"EN"}',
    );
    dio.httpClientAdapter = adapter;

    final result = await LocalePreferenceRepository(
      dio,
    ).update(LocalePreference.english);

    expect(result, LocalePreference.english);
    expect(adapter.request?.path, '/me/preferences/language');
    expect(adapter.request?.method, 'PUT');
    expect(adapter.request?.headers['Accept-Language'], 'en');
    expect(adapter.request?.data, {'languagePreference': 'EN'});
  });
}

class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter(this.responseBody);

  final String responseBody;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      responseBody,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _EmptyTokenStore implements TokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> save(AuthSession session) async {}
}
