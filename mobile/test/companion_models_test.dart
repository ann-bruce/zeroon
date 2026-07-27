import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/companion/companion_models.dart';

void main() {
  test('companion request sends an explicit server-reviewed purpose', () {
    final request = CompanionMessageRequest(
      conversationId: 7,
      purpose: CompanionPurpose.archiveObservation,
      message: '  observe this  ',
    );

    expect(request.toJson(), {
      'conversationId': 7,
      'purpose': 'ARCHIVE_OBSERVATION',
      'message': 'observe this',
    });
  });

  test('companion chat remains the backward-compatible default purpose', () {
    const request = CompanionMessageRequest(message: 'hello');

    expect(request.toJson()['purpose'], 'COMPANION_CHAT');
  });
}
