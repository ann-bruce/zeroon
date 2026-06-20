import '../state/state_models.dart';

class CreateRecordRequest {
  const CreateRecordRequest({
    required this.state,
    this.goal,
    this.content,
  });

  final String state;
  final String? goal;
  final String? content;

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      if (_hasText(goal)) 'goal': goal!.trim(),
      if (_hasText(content)) 'content': content!.trim(),
    };
  }

  bool get hasContent => _hasText(goal) || _hasText(content);
}

class ZeroRecord {
  const ZeroRecord({
    required this.id,
    required this.state,
    this.goal,
    this.content,
    this.aiSummary,
    required this.createdAt,
  });

  final int id;
  final String state;
  final String? goal;
  final String? content;
  final String? aiSummary;
  final DateTime createdAt;

  factory ZeroRecord.fromJson(Map<String, dynamic> json) {
    return ZeroRecord(
      id: json['id'] as int,
      state: json['state'] as String,
      goal: json['goal'] as String?,
      content: json['content'] as String?,
      aiSummary: json['aiSummary'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class RecordPage {
  const RecordPage({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
  });

  final List<ZeroRecord> items;
  final int page;
  final int size;
  final int totalElements;

  factory RecordPage.fromJson(Map<String, dynamic> json) {
    return RecordPage(
      items: (json['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ZeroRecord.fromJson)
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalElements: json['totalElements'] as int,
    );
  }
}

String recordPreview(ZeroRecord record) {
  if (_hasText(record.content)) {
    return record.content!.trim();
  }
  if (_hasText(record.goal)) {
    return record.goal!.trim();
  }
  return record.state;
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

const recordStates = zeroonStates;
