import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/support/support_models.dart';
import 'package:zeroon_mobile/support/support_repository.dart';

void main() {
  test('creates a support request without diagnostics unless consented',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'));
    final adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;

    final receipt = await SupportRepository(dio).create(
      const CreateSupportRequest(
        clientSubmissionId: '32a052c7-e395-4a58-9fb7-122da15fe7f2',
        category: SupportCategory.suggestion,
        subject: 'A calmer support entry',
        description: 'A calmer support entry would help.',
        diagnosticConsent: false,
      ),
    );

    expect(adapter.request?.path, '/support/requests');
    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.data, {
      'clientSubmissionId': '32a052c7-e395-4a58-9fb7-122da15fe7f2',
      'category': 'SUGGESTION',
      'subject': 'A calmer support entry',
      'description': 'A calmer support entry would help.',
      'diagnosticConsent': false,
    });
    expect(receipt.reference, 'ZRN-260723-AB12CD');
    expect(receipt.status, 'RECEIVED');
  });

  test('lists owned requests, reads detail, and posts a follow-up', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'));
    final adapter = _SupportFlowAdapter();
    dio.httpClientAdapter = adapter;
    final repository = SupportRepository(dio);

    final page = await repository.list(page: 1, size: 10);
    final detail = await repository.get('ZS-1234567890ABCDEF1234');
    final message = await repository.addMessage(
      'ZS-1234567890ABCDEF1234',
      '  Exact follow-up  ',
    );

    expect(page.items.single.status, SupportRequestStatus.waitingForUser);
    expect(page.totalElements, 11);
    expect(detail.messages.single.actorType, SupportActorType.admin);
    expect(detail.statusHistory.length, 2);
    expect(message.body, '  Exact follow-up  ');
    expect(adapter.requests[0].queryParameters, {'page': 1, 'size': 10});
    expect(adapter.requests[1].path,
        '/me/support-requests/ZS-1234567890ABCDEF1234');
    expect(
      adapter.requests[2].path,
      '/me/support-requests/ZS-1234567890ABCDEF1234/messages',
    );
    expect(adapter.requests[2].data, {'body': '  Exact follow-up  '});
  });
}

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      '''
      {
        "reference": "ZRN-260723-AB12CD",
        "category": "SUGGESTION",
        "status": "RECEIVED",
        "subject": "A calmer support entry",
        "createdAt": "2026-07-23T06:00:00Z"
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

class _SupportFlowAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = switch (options.path) {
      '/me/support-requests' => '''
        {
          "items": [{
            "reference": "ZS-1234567890ABCDEF1234",
            "category": "PRODUCT_PROBLEM",
            "status": "WAITING_FOR_USER",
            "subject": "Archive did not refresh",
            "createdAt": "2026-07-22T06:00:00Z",
            "updatedAt": "2026-07-23T06:00:00Z"
          }],
          "page": 1,
          "size": 10,
          "totalElements": 11
        }
      ''',
      '/me/support-requests/ZS-1234567890ABCDEF1234/messages' => '''
        {
          "id": 9,
          "actorType": "USER",
          "body": "  Exact follow-up  ",
          "createdAt": "2026-07-23T07:00:00Z"
        }
      ''',
      _ => '''
        {
          "reference": "ZS-1234567890ABCDEF1234",
          "category": "PRODUCT_PROBLEM",
          "status": "WAITING_FOR_USER",
          "subject": "Archive did not refresh",
          "description": "The archive did not refresh after Reset.",
          "messages": [{
            "id": 8,
            "actorType": "ADMIN",
            "body": "Which device were you using?",
            "createdAt": "2026-07-23T06:00:00Z"
          }],
          "statusHistory": [{
            "fromStatus": null,
            "toStatus": "RECEIVED",
            "actorType": "SYSTEM",
            "createdAt": "2026-07-22T06:00:00Z"
          }, {
            "fromStatus": "IN_REVIEW",
            "toStatus": "WAITING_FOR_USER",
            "actorType": "ADMIN",
            "createdAt": "2026-07-23T06:00:00Z"
          }],
          "createdAt": "2026-07-22T06:00:00Z",
          "updatedAt": "2026-07-23T06:00:00Z",
          "closedAt": null
        }
      ''',
    };
    return ResponseBody.fromString(
      body,
      options.method == 'POST' ? 201 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
