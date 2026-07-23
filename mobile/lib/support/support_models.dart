enum SupportCategory {
  productProblem('PRODUCT_PROBLEM'),
  suggestion('SUGGESTION'),
  accountDataPrivacy('ACCOUNT_DATA_PRIVACY'),
  aiResponseSafety('AI_RESPONSE_SAFETY'),
  complaintRights('COMPLAINT_RIGHTS'),
  other('OTHER');

  const SupportCategory(this.wireValue);

  final String wireValue;

  static SupportCategory fromWire(String value) {
    return SupportCategory.values.firstWhere(
      (category) => category.wireValue == value,
    );
  }
}

enum SupportRequestStatus {
  received('RECEIVED'),
  inReview('IN_REVIEW'),
  waitingForUser('WAITING_FOR_USER'),
  replied('REPLIED'),
  closed('CLOSED');

  const SupportRequestStatus(this.wireValue);

  final String wireValue;

  static SupportRequestStatus fromWire(String value) {
    return SupportRequestStatus.values.firstWhere(
      (status) => status.wireValue == value,
    );
  }
}

enum SupportActorType {
  system('SYSTEM'),
  user('USER'),
  admin('ADMIN');

  const SupportActorType(this.wireValue);

  final String wireValue;

  static SupportActorType fromWire(String value) {
    return SupportActorType.values.firstWhere(
      (actor) => actor.wireValue == value,
    );
  }
}

class SupportDiagnosticEnvelope {
  const SupportDiagnosticEnvelope({
    required this.appVersion,
    required this.build,
    required this.platform,
    required this.locale,
    required this.timestamp,
    this.osFamily,
  });

  final String appVersion;
  final String build;
  final String platform;
  final String? osFamily;
  final String locale;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'appVersion': appVersion,
        'build': build,
        'platform': platform,
        if (osFamily != null) 'osFamily': osFamily,
        'locale': locale,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };
}

class CreateSupportRequest {
  const CreateSupportRequest({
    required this.clientSubmissionId,
    required this.category,
    required this.subject,
    required this.description,
    required this.diagnosticConsent,
    this.diagnostics,
  });

  final String clientSubmissionId;
  final SupportCategory category;
  final String subject;
  final String description;
  final bool diagnosticConsent;
  final SupportDiagnosticEnvelope? diagnostics;

  Map<String, dynamic> toJson() => {
        'clientSubmissionId': clientSubmissionId,
        'category': category.wireValue,
        'subject': subject,
        'description': description,
        'diagnosticConsent': diagnosticConsent,
        if (diagnostics != null) 'diagnostics': diagnostics!.toJson(),
      };
}

class SupportReceipt {
  const SupportReceipt({
    required this.reference,
    required this.category,
    required this.status,
    required this.subject,
    required this.createdAt,
  });

  factory SupportReceipt.fromJson(Map<String, dynamic> json) {
    return SupportReceipt(
      reference: json['reference'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      subject: json['subject'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String reference;
  final String category;
  final String status;
  final String subject;
  final DateTime createdAt;
}

class SupportRequestSummary {
  const SupportRequestSummary({
    required this.reference,
    required this.category,
    required this.status,
    required this.subject,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportRequestSummary.fromJson(Map<String, dynamic> json) {
    return SupportRequestSummary(
      reference: json['reference'] as String,
      category: SupportCategory.fromWire(json['category'] as String),
      status: SupportRequestStatus.fromWire(json['status'] as String),
      subject: json['subject'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String reference;
  final SupportCategory category;
  final SupportRequestStatus status;
  final String subject;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class SupportRequestPage {
  const SupportRequestPage({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
  });

  factory SupportRequestPage.fromJson(Map<String, dynamic> json) {
    return SupportRequestPage(
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => SupportRequestSummary.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalElements: json['totalElements'] as int,
    );
  }

  final List<SupportRequestSummary> items;
  final int page;
  final int size;
  final int totalElements;
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.actorType,
    required this.body,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as int,
      actorType: SupportActorType.fromWire(json['actorType'] as String),
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int id;
  final SupportActorType actorType;
  final String body;
  final DateTime createdAt;
}

class SupportStatusChange {
  const SupportStatusChange({
    required this.toStatus,
    required this.actorType,
    required this.createdAt,
    this.fromStatus,
  });

  factory SupportStatusChange.fromJson(Map<String, dynamic> json) {
    final fromStatus = json['fromStatus'] as String?;
    return SupportStatusChange(
      fromStatus:
          fromStatus == null ? null : SupportRequestStatus.fromWire(fromStatus),
      toStatus: SupportRequestStatus.fromWire(json['toStatus'] as String),
      actorType: SupportActorType.fromWire(json['actorType'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final SupportRequestStatus? fromStatus;
  final SupportRequestStatus toStatus;
  final SupportActorType actorType;
  final DateTime createdAt;
}

class SupportRequestDetail {
  const SupportRequestDetail({
    required this.reference,
    required this.category,
    required this.status,
    required this.subject,
    required this.description,
    required this.messages,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
  });

  factory SupportRequestDetail.fromJson(Map<String, dynamic> json) {
    return SupportRequestDetail(
      reference: json['reference'] as String,
      category: SupportCategory.fromWire(json['category'] as String),
      status: SupportRequestStatus.fromWire(json['status'] as String),
      subject: json['subject'] as String,
      description: json['description'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map(
            (item) => SupportMessage.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      statusHistory: (json['statusHistory'] as List<dynamic>)
          .map(
            (item) =>
                SupportStatusChange.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
    );
  }

  final String reference;
  final SupportCategory category;
  final SupportRequestStatus status;
  final String subject;
  final String description;
  final List<SupportMessage> messages;
  final List<SupportStatusChange> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  SupportRequestDetail withUserFollowUp(SupportMessage message) {
    final nextStatus = switch (status) {
      SupportRequestStatus.waitingForUser ||
      SupportRequestStatus.replied =>
        SupportRequestStatus.inReview,
      _ => status,
    };
    return SupportRequestDetail(
      reference: reference,
      category: category,
      status: nextStatus,
      subject: subject,
      description: description,
      messages: [...messages, message],
      statusHistory: statusHistory,
      createdAt: createdAt,
      updatedAt: message.createdAt,
      closedAt: closedAt,
    );
  }
}
