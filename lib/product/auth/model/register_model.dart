class RegisterRequest {
  final String gsmNumber;
  final String fullName;
  final String password;
  final String inviteToken;

  const RegisterRequest({
    required this.gsmNumber,
    required this.fullName,
    required this.password,
    required this.inviteToken,
  });

  Map<String, dynamic> toJson() => {
        'gsm_number': gsmNumber,
        'full_name': fullName,
        'password': password,
        'invite_token': inviteToken,
      };
}

class RegisterResponse {
  final bool success;
  final String? message;
  final String? userId;

  const RegisterResponse({
    required this.success,
    this.message,
    this.userId,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String?,
        userId: json['user_id'] as String?,
      );
}
