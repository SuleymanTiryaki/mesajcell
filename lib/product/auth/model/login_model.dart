/// Telefon numarası ile giriş isteği
class LoginRequest {
  final String phoneNumber;
  final String password;

  LoginRequest({required this.phoneNumber, required this.password});

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'password': password,
      };
}

/// Telefon + şifre cevabı → OTP tetiklenir
class LoginResponse {
  final bool success;
  final String? message;
  final String? userId;

  LoginResponse({
    required this.success,
    this.message,
    this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String?,
        userId: (json['data']?['user_id'] ?? json['userId'])?.toString(),
      );
}
