class GrowthSummary {
  const GrowthSummary({
    required this.preservedMoments,
    this.firstRecordDate,
    required this.companionDays,
    required this.timezone,
    required this.calculatedAt,
  });

  final int preservedMoments;
  final DateTime? firstRecordDate;
  final int companionDays;
  final String timezone;
  final DateTime calculatedAt;

  factory GrowthSummary.fromJson(Map<String, dynamic> json) {
    final firstRecordDate = json['firstRecordDate'] as String?;
    return GrowthSummary(
      preservedMoments: _asInt(json['preservedMoments']),
      firstRecordDate:
          firstRecordDate == null ? null : DateTime.parse(firstRecordDate),
      companionDays: _asInt(json['companionDays']),
      timezone: json['timezone'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Expected int for growth metric, got $value');
}

class StatePatternSummary {
  const StatePatternSummary({
    required this.days,
    required this.sampleSize,
    required this.timezone,
    required this.calculatedAt,
  });

  final int days;
  final int sampleSize;
  final String timezone;
  final DateTime calculatedAt;

  factory StatePatternSummary.fromJson(Map<String, dynamic> json) {
    return StatePatternSummary(
      days: json['days'] as int,
      sampleSize: _asInt(json['sampleSize']),
      timezone: json['timezone'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}
