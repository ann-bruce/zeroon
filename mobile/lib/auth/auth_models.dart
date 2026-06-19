class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final ZeroonUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      user: ZeroonUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'user': user.toJson(),
    };
  }
}

class ZeroonUser {
  const ZeroonUser({
    required this.uid,
    required this.mobile,
    required this.currentState,
  });

  final String uid;
  final String? mobile;
  final String currentState;

  factory ZeroonUser.fromJson(Map<String, dynamic> json) {
    return ZeroonUser(
      uid: json['uid'] as String,
      mobile: json['mobile'] as String?,
      currentState: json['currentState'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'mobile': mobile, 'currentState': currentState};
  }
}
