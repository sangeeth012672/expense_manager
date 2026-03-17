class AuthResponse {
  final bool isSuccess;
  final String? message;
  final bool? userExists;
  final String? token;
  final String? nickname;

  AuthResponse({
    required this.isSuccess,
    this.message,
    this.userExists,
    this.token,
    this.nickname,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      isSuccess: json['status'] == 'success',
      message: json['message'] as String?,
      userExists: json['user_exists'] as bool?,
      token: json['token'] as String?,
      nickname: json['nickname'] as String?,
    );
  }
}
