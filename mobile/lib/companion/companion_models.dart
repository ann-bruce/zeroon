class CompanionMessageRequest {
  const CompanionMessageRequest({
    this.conversationId,
    required this.message,
  });

  final int? conversationId;
  final String message;

  Map<String, dynamic> toJson() {
    return {
      if (conversationId != null) 'conversationId': conversationId,
      'message': message.trim(),
    };
  }
}

class CompanionMessageResponse {
  const CompanionMessageResponse({
    required this.conversationId,
    required this.messageId,
    required this.reply,
    required this.safetyNotice,
  });

  final int conversationId;
  final int messageId;
  final String reply;
  final String safetyNotice;

  factory CompanionMessageResponse.fromJson(Map<String, dynamic> json) {
    return CompanionMessageResponse(
      conversationId: json['conversationId'] as int,
      messageId: json['messageId'] as int,
      reply: json['reply'] as String,
      safetyNotice: json['safetyNotice'] as String,
    );
  }
}
