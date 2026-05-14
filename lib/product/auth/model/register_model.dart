class RegisterRequest {
  final String gsmNumber;
  final String fullName;
  final String email;
  final String password;
  final String orgId;

  const RegisterRequest({
    required this.gsmNumber,
    required this.fullName,
    required this.email,
    required this.password,
    required this.orgId,
  });

  Map<String, dynamic> toJson() => {
        'gsm_number': gsmNumber,
        'full_name': fullName,
        'email': email,
        'password': password,
        'org_id': orgId,
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
