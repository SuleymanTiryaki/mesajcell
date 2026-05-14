part of 'register_admin_cubit.dart';

enum RegisterAdminStatus {
  initial,
  loading,
  success,      // kayıt tamam, OTP bekleniyor
  loginSuccess, // OTP doğrulandı → ana sayfaya geç
  error,
}

class RegisterAdminState {
  final RegisterAdminStatus status;
  final String? errorMessage;
  final AuthedUser? user;

  const RegisterAdminState({
    this.status = RegisterAdminStatus.initial,
    this.errorMessage,
    this.user,
  });

  RegisterAdminState copyWith({
    RegisterAdminStatus? status,
    String? errorMessage,
    AuthedUser? user,
  }) =>
      RegisterAdminState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        user: user ?? this.user,
      );

  RegisterAdminState clearError() =>
      RegisterAdminState(status: RegisterAdminStatus.initial, user: user);
}
