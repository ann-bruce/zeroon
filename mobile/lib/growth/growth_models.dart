class GrowthSummary {
  const GrowthSummary({
    required this.continuousResetDays,
    required this.cachedEntries,
    this.firstRecordDate,
    required this.companionDays,
    required this.timezone,
    required this.calculatedAt,
  });

  final int continuousResetDays;
  final int cachedEntries;
  final DateTime? firstRecordDate;
  final int companionDays;
  final String timezone;
  final DateTime calculatedAt;

  factory GrowthSummary.fromJson(Map<String, dynamic> json) {
    final firstRecordDate = json['firstRecordDate'] as String?;
    return GrowthSummary(
      continuousResetDays: _asInt(json['continuousResetDays']),
      cachedEntries: _asInt(json['cachedEntries']),
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
    this.dominantState,
    required this.distribution,
    required this.observation,
    required this.dataSources,
    required this.timezone,
    required this.calculatedAt,
  });

  final int days;
  final int sampleSize;
  final String? dominantState;
  final Map<String, int> distribution;
  final String observation;
  final List<String> dataSources;
  final String timezone;
  final DateTime calculatedAt;

  factory StatePatternSummary.fromJson(Map<String, dynamic> json) {
    final rawDistribution = json['distribution'] as Map<String, dynamic>;
    return StatePatternSummary(
      days: json['days'] as int,
      sampleSize: json['sampleSize'] as int,
      dominantState: json['dominantState'] as String?,
      distribution: rawDistribution.map(
        (key, value) => MapEntry(key, value as int),
      ),
      observation: json['observation'] as String,
      dataSources: (json['dataSources'] as List<dynamic>).cast<String>(),
      timezone: json['timezone'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}
