/// Telefon numarası ile giriş isteği
class LoginRequest {
  final String gsmNumber;
  final String password;

  LoginRequest({required this.gsmNumber, required this.password});

  Map<String, dynamic> toJson() => {
        'gsm_number': gsmNumber,
        'password': password,
      };
}

/// Telefon + şifre cevabı → token döner, direkt giriş
class LoginResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;

  LoginResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      accessToken: data?['access_token'] as String?,
      refreshToken: data?['refresh_token'] as String?,
    );
  }
}
