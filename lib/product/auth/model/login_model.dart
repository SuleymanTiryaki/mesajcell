/// Telefon numarası ile giriş isteği
class LoginRequest {
  final String phoneNumber;
  final String password;

  LoginRequest({required this.phoneNumber, required this.password});

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'password': password,
      };
}

/// Telefon + şifre cevabı → OTP gönderir
class LoginResponse {
  final bool? success;
  final String? message;
  final String? userId; // TODO: API'ye göre güncellenecek

  LoginResponse({this.success, this.message, this.userId});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json['success'],
        message: json['message'],
        userId: json['userId']?.toString(),
      );
}
