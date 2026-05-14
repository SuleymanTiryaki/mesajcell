/// OTP doğrulama isteği
class OtpRequest {
  final String gsmNumber;
  final String otpCode;

  OtpRequest({required this.gsmNumber, required this.otpCode});

  Map<String, dynamic> toJson() => {
        'gsm_number': gsmNumber,
        'otp_code': otpCode,
      };
}

/// Kullanıcı bilgisi (OTP yanıtı içinde gelir)
class AuthedUser {
  final String id;
  final String fullName;
  final String gsmNumber;
  final String email;
  final String role;
  final String orgId;
  final String presenceStatus;
  final String? profilePhotoUrl;

  const AuthedUser({
    required this.id,
    required this.fullName,
    required this.gsmNumber,
    required this.email,
    required this.role,
    required this.orgId,
    required this.presenceStatus,
    this.profilePhotoUrl,
  });

  factory AuthedUser.fromJson(Map<String, dynamic> json) => AuthedUser(
        id: json['id'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        gsmNumber: json['gsm_number'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? '',
        orgId: json['org_id'] as String? ?? '',
        presenceStatus: json['presence_status'] as String? ?? 'offline',
        profilePhotoUrl: json['profile_photo_url'] as String?,
      );
}

/// OTP doğrulama cevabı
class OtpResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final AuthedUser? user;

  const OtpResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return OtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      accessToken: data?['access_token'] as String?,
      refreshToken: data?['refresh_token'] as String?,
      user: data?['user'] != null
          ? AuthedUser.fromJson(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

