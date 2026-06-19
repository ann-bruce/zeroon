class StateSnapshot {
  const StateSnapshot({
    required this.state,
    required this.source,
    required this.changedAt,
  });

  final String state;
  final String source;
  final DateTime changedAt;

  factory StateSnapshot.fromJson(Map<String, dynamic> json) {
    return StateSnapshot(
      state: json['state'] as String,
      source: json['source'] as String,
      changedAt: DateTime.parse(json['changedAt'] as String),
    );
  }
}

const zeroonStates = [
  'CALM',
  'FOCUS',
  'CREATE',
  'TIRED',
  'OVERLOAD',
  'CONFUSED',
];
