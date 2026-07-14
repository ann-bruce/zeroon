class MemoryEntry {
  const MemoryEntry({
    required this.id,
    required this.type,
    this.title,
    required this.summary,
    required this.importance,
    this.sourceType,
    this.sourceId,
    this.expiresAt,
    required this.enabled,
    required this.aiContextEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String type;
  final String? title;
  final String summary;
  final int importance;
  final String? sourceType;
  final int? sourceId;
  final DateTime? expiresAt;
  final bool enabled;
  final bool aiContextEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MemoryEntry.fromJson(Map<String, dynamic> json) {
    return MemoryEntry(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String?,
      summary: json['summary'] as String,
      importance: json['importance'] as int,
      sourceType: json['sourceType'] as String?,
      sourceId: json['sourceId'] as int?,
      expiresAt: _parseDateTime(json['expiresAt']),
      enabled: json['enabled'] as bool,
      aiContextEnabled: json['aiContextEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class MemoryPage {
  const MemoryPage({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
  });

  final List<MemoryEntry> items;
  final int page;
  final int size;
  final int totalElements;

  factory MemoryPage.fromJson(Map<String, dynamic> json) {
    return MemoryPage(
      items: (json['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(MemoryEntry.fromJson)
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalElements: json['totalElements'] as int,
    );
  }

  MemoryPage replace(MemoryEntry entry) {
    return MemoryPage(
      items: [
        for (final item in items)
          if (item.id == entry.id) entry else item,
      ],
      page: page,
      size: size,
      totalElements: totalElements,
    );
  }

  MemoryPage remove(int memoryId) {
    return MemoryPage(
      items: items.where((item) => item.id != memoryId).toList(),
      page: page,
      size: size,
      totalElements: totalElements > 0 ? totalElements - 1 : 0,
    );
  }
}

class UpdateMemoryControlsRequest {
  const UpdateMemoryControlsRequest({this.enabled, this.aiContextEnabled});

  final bool? enabled;
  final bool? aiContextEnabled;

  Map<String, dynamic> toJson() {
    return {
      if (enabled != null) 'enabled': enabled,
      if (aiContextEnabled != null) 'aiContextEnabled': aiContextEnabled,
    };
  }
}

DateTime? _parseDateTime(Object? value) {
  return value is String ? DateTime.parse(value) : null;
}
