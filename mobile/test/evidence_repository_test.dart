import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/evidence/evidence_models.dart';
import 'package:zeroon_mobile/evidence/evidence_repository.dart';

void main() {
  test('submits only the reviewed content-free event envelope', () async {
    final adapter = _EvidenceAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'))
      ..httpClientAdapter = adapter;
    final repository = EvidenceRepository(dio);

    await repository.record(EvidenceEvent(
      'RECORD_SAVED',
      const {
        'state': 'CALM',
        'hasGoal': true,
        'hasContent': false,
        'latencyBucket': 'UNDER_500_MS',
        'retryCountBucket': 'ZERO',
      },
      occurredAt: DateTime.utc(2026, 7, 22, 18),
      clientEventId: '32a052c7-e395-4a58-9fb7-122da15fe7f2',
    ));

    expect(adapter.requests.single.data, {
      'clientEventId': '32a052c7-e395-4a58-9fb7-122da15fe7f2',
      'eventName': 'RECORD_SAVED',
      'schemaVersion': 1,
      'occurredDate': '2026-07-23',
      'state': 'CALM',
      'hasGoal': true,
      'hasContent': false,
      'latencyBucket': 'UNDER_500_MS',
      'retryCountBucket': 'ZERO',
    });
    expect(repository.pendingCount, 0);
  });

  test('network failure is isolated and the bounded queue keeps no more than 2',
      () async {
    final adapter = _EvidenceAdapter(failures: 10);
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'))
      ..httpClientAdapter = adapter;
    final repository = EvidenceRepository(dio, maxQueueSize: 2);

    for (var index = 0; index < 3; index++) {
      await repository.record(
        EvidenceEvent(
          'STATE_STARTED',
          const {'state': 'CALM', 'source': 'MANUAL'},
        ),
      );
    }

    expect(repository.pendingCount, 2);
  });

  test('a later flush retries the same client event id', () async {
    final adapter = _EvidenceAdapter(failures: 1);
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'))
      ..httpClientAdapter = adapter;
    final repository = EvidenceRepository(dio);
    final event = EvidenceEvent(
      'STATE_STARTED',
      const {'state': 'FOCUS', 'source': 'MANUAL'},
      clientEventId: '32a052c7-e395-4a58-9fb7-122da15fe7f2',
    );

    await repository.record(event);
    expect(repository.pendingCount, 1);
    await repository.flush();

    expect(repository.pendingCount, 0);
    expect(
      adapter.requests.map((request) => request.data['clientEventId']),
      everyElement(event.clientEventId),
    );
  });
}

class _EvidenceAdapter implements HttpClientAdapter {
  _EvidenceAdapter({this.failures = 0});

  int failures;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (failures > 0) {
      failures -= 1;
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromString(
      '''
      {
        "stored": true,
        "duplicate": false,
        "clientEventId": "${options.data['clientEventId']}",
        "eventName": "${options.data['eventName']}"
      }
      ''',
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
