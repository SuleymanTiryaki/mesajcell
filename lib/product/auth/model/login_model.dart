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
  final String? userId;
  final String? orgId;
  final String? role;

  LoginResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.orgId,
    this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    // Backend bazen user objesinde, bazen doğrudan data'da döner
    final user = data?['user'] as Map<String, dynamic>?;
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      accessToken: data?['access_token'] as String?,
      refreshToken: data?['refresh_token'] as String?,
      userId: (user?['id'] ?? data?['user_id'])?.toString(),
      orgId: (user?['org_id'] ?? data?['org_id'])?.toString(),
      role: (user?['role'] ?? data?['role'])?.toString(),
    );
  }
}
