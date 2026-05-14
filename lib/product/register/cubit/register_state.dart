part of 'register_cubit.dart';

enum RegisterStatus {
  initial,
  loading,
  success,     // kayıt tamam, OTP bekleniyor
  loginSuccess, // OTP doğrulandı → ana sayfaya geç
  error,
}

class RegisterState {
  final RegisterStatus status;
  final String? errorMessage;
  final AuthedUser? user;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.user,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    AuthedUser? user,
  }) =>
      RegisterState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        user: user ?? this.user,
      );

  RegisterState clearError() =>
      RegisterState(status: RegisterStatus.initial, user: user);
}
