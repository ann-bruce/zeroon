class UserProfile {
  const UserProfile({
    this.nickname,
    this.avatarPreset,
    this.ageRange,
    this.occupation,
    this.selfDescription,
    required this.aiProfileContextEnabled,
    this.createdAt,
    this.updatedAt,
  });

  final String? nickname;
  final String? avatarPreset;
  final String? ageRange;
  final String? occupation;
  final String? selfDescription;
  final bool aiProfileContextEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'] as String?,
      avatarPreset: json['avatarPreset'] as String?,
      ageRange: json['ageRange'] as String?,
      occupation: json['occupation'] as String?,
      selfDescription: json['selfDescription'] as String?,
      aiProfileContextEnabled:
          json['aiProfileContextEnabled'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
}

class UpdateUserProfileRequest {
  const UpdateUserProfileRequest({
    this.nickname,
    this.avatarPreset,
    this.ageRange,
    this.occupation,
    this.selfDescription,
    required this.aiProfileContextEnabled,
  });

  final String? nickname;
  final String? avatarPreset;
  final String? ageRange;
  final String? occupation;
  final String? selfDescription;
  final bool aiProfileContextEnabled;

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatarPreset': avatarPreset,
      'ageRange': ageRange,
      'occupation': occupation,
      'selfDescription': selfDescription,
      'aiProfileContextEnabled': aiProfileContextEnabled,
    };
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String);
}
