part of 'auth_cubit.dart';

/// Akış adımı — hangi ekranda olduğumuzu tutar
enum AuthStep {
  phone,  // 1. Adım: Telefon + şifre
  otp,    // 2. Adım: OTP doğrulama
}

/// İşlem durumu
enum AuthStatus {
  initial,
  loading,
  success,
  error,
  otpSent,       // login başarılı → OTP tetiklendi
  otpVerified,   // OTP doğrulandı → eve git
  otpResent,     // OTP yeniden gönderildi
}

class AuthState {
  final AuthStep step;
  final AuthStatus status;
  final String? errorMessage;
  final String? phoneNumber; // login sonrası bir sonraki adıma taşınır

  const AuthState({
    this.step = AuthStep.phone,
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.phoneNumber,
  });

  AuthState copyWith({
    AuthStep? step,
    AuthStatus? status,
    String? errorMessage,
    String? phoneNumber,
  }) =>
      AuthState(
        step: step ?? this.step,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );

  /// Hata mesajını sıfırlamak için
  AuthState clearError() => AuthState(
        step: step,
        status: AuthStatus.initial,
        phoneNumber: phoneNumber,
      );
}
