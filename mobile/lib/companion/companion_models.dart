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
    this.outcome = 'SUCCESS',
    this.latencyBucket = 'UNDER_500_MS',
    this.promptVersion = 'COMPANION_REFLECTION_V1',
    this.modelAlias = 'PRIMARY',
    this.contextClasses = const [],
  });

  final int conversationId;
  final int messageId;
  final String reply;
  final String safetyNotice;
  final String outcome;
  final String latencyBucket;
  final String promptVersion;
  final String modelAlias;
  final List<String> contextClasses;

  factory CompanionMessageResponse.fromJson(Map<String, dynamic> json) {
    return CompanionMessageResponse(
      conversationId: json['conversationId'] as int,
      messageId: json['messageId'] as int,
      reply: json['reply'] as String,
      safetyNotice: json['safetyNotice'] as String,
      outcome: json['outcome'] as String,
      latencyBucket: json['latencyBucket'] as String,
      promptVersion: json['promptVersion'] as String,
      modelAlias: json['modelAlias'] as String,
      contextClasses: (json['contextClasses'] as List<dynamic>).cast<String>(),
    );
  }
}
