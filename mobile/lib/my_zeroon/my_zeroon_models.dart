class MyZeroonCompanion {
  const MyZeroonCompanion({
    required this.met,
    this.companionKey,
    this.displayName,
    this.nameplateSerial,
    this.metAt,
    this.createdAt,
    this.updatedAt,
  });

  final bool met;
  final String? companionKey;
  final String? displayName;
  final String? nameplateSerial;
  final DateTime? metAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MyZeroonCompanion.fromJson(Map<String, dynamic> json) {
    return MyZeroonCompanion(
      met: json['met'] as bool? ?? false,
      companionKey: json['companionKey'] as String?,
      displayName: json['displayName'] as String?,
      nameplateSerial: json['nameplateSerial'] as String?,
      metAt: _parseDateTime(json['metAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
}

class MeetMyZeroonRequest {
  const MeetMyZeroonRequest({this.companionKey = 'ZEROON_DEFAULT'});

  final String? companionKey;

  Map<String, dynamic> toJson() {
    return {'companionKey': companionKey};
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String);
}
