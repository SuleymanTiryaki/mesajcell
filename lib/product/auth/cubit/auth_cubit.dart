import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/app_session.dart';
import '../model/login_model.dart';
import '../model/otp_model.dart';
import '../service/IAuth_service.dart'; // ignore: file_names

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthService service;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  AuthCubit({required this.service}) : super(const AuthState());

  @override
  Future<void> close() {
    phoneController.dispose();
    passwordController.dispose();
    otpController.dispose();
    return super.close();
  }

  // ─── 1. Adım: Telefon + Şifre ile Giriş ───────────────────────────────────

  Future<void> login() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty || phone.length < 10) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Geçerli bir telefon numarası girin.',
      ));
      return;
    }
    if (password.isEmpty || password.length < 6) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Şifre en az 6 karakter olmalıdır.',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await service.postLogin(
        LoginRequest(gsmNumber: phone, password: password),
      );

      if (response == null) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Sunucuya bağlanılamadı.',
        ));
        return;
      }

      if (response.success) {
        AppLogger.i('[AuthCubit] Login başarılı → ana sayfa');
        if (response.accessToken != null) {
          AppSession.instance.setTokens(
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken,
          );
        }
        emit(state.copyWith(status: AuthStatus.loginSuccess));
      } else {
        AppLogger.w('[AuthCubit] login başarısız: ${response.message}');
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.message ?? 'Giriş başarısız.',
        ));
      }
    } catch (e, st) {
      AppLogger.e('[AuthCubit] login hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── 2. Adım: OTP Doğrulama ────────────────────────────────────────────────

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    final phone = state.phoneNumber ?? phoneController.text.trim();

    if (otp.isEmpty || otp.length < 4) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Lütfen doğrulama kodunu girin.',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await service.postVerifyOtp(
        OtpRequest(gsmNumber: phone, otpCode: otp),
      );

      if (response?.success == true) {
        AppLogger.i('[AuthCubit] OTP doğrulandı → ana sayfaya yönlendir');
        if (response!.accessToken != null) {
          AppSession.instance.setTokens(
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken,
          );
        }
        emit(state.copyWith(status: AuthStatus.otpVerified));
      } else {
        AppLogger.w('[AuthCubit] OTP hatalı: ${response?.message}');
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: response?.message ?? 'Kod hatalı veya süresi dolmuş.',
        ));
      }
    } catch (e, st) {
      AppLogger.e('[AuthCubit] verifyOtp hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── OTP Yeniden Gönder ────────────────────────────────────────────────────

  Future<void> resendOtp() async {
    final phone = state.phoneNumber ?? phoneController.text.trim();
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final success = await service.postResendOtp(phone);
      emit(state.copyWith(
        status: success ? AuthStatus.otpResent : AuthStatus.error,
        errorMessage: success ? null : 'Kod gönderilemedi, tekrar deneyin.',
      ));
      if (success) AppLogger.i('[AuthCubit] OTP yeniden gönderildi');
    } catch (e, st) {
      AppLogger.e('[AuthCubit] resendOtp hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Geri: OTP → Phone ─────────────────────────────────────────────────────

  void backToPhone() {
    otpController.clear();
    emit(state.copyWith(
      step: AuthStep.phone,
      status: AuthStatus.initial,
      errorMessage: null,
    ));
  }

  /// Hata mesajını sıfırla (snackbar sonrası kullanım için)
  void clearError() => emit(state.clearError());

  // ─── Çıkış Yap ─────────────────────────────────────────────────────────────

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await service.postLogout();
    } catch (_) {
      // API hatası olsa bile session temizlensin
    }
    AppSession.instance.clear();
    AppLogger.i('[AuthCubit] Çıkış yapıldı');
    emit(state.copyWith(status: AuthStatus.loggedOut));
  }
}
