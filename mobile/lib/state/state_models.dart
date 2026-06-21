class StateSnapshot {
  const StateSnapshot({
    required this.state,
    required this.source,
    required this.changedAt,
    this.sessionId,
    this.startedAt,
    this.elapsedSeconds = 0,
  });

  final String state;
  final String source;
  final DateTime changedAt;
  final int? sessionId;
  final DateTime? startedAt;
  final int elapsedSeconds;

  factory StateSnapshot.fromJson(Map<String, dynamic> json) {
    return StateSnapshot(
      state: json['state'] as String,
      source: json['source'] as String,
      changedAt: DateTime.parse(json['changedAt'] as String),
      sessionId: json['sessionId'] as int?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
    );
  }

  bool get hasActiveSession => sessionId != null;
}

const zeroonStates = [
  'CALM',
  'FOCUS',
  'CREATE',
  'TIRED',
  'OVERLOAD',
  'CONFUSED',
];
