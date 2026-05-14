import 'package:dio/dio.dart';
import '../model/login_model.dart';
import '../model/otp_model.dart';
import '../model/register_model.dart';
import '../model/register_admin_model.dart';

/// Auth servis arayüzü — API URL'leri gelince service impl güncellenir
abstract class IAuthService {
  final Dio dio;
  IAuthService(this.dio);

  static const String loginPath = '/api/v1/auth/login';
  static const String verifyOtpPath = '/api/v1/auth/verify-otp';
  static const String resendOtpPath = '/api/v1/auth/resend-otp';
  static const String registerPath = '/api/v1/auth/register';
  static const String registerAdminPath = '/api/v1/auth/register-admin';
  static const String logoutPath = '/api/v1/auth/logout';

  /// 1. Adım: Telefon + şifre ile giriş → OTP tetiklenir
  Future<LoginResponse?> postLogin(LoginRequest request);

  /// 2. Adım: OTP kodu doğrulama → token alınır
  Future<OtpResponse?> postVerifyOtp(OtpRequest request);

  /// Opsiyonel: OTP yeniden gönder
  Future<bool> postResendOtp(String phoneNumber);

  /// Kayıt ol (davetle katıl)
  Future<RegisterResponse?> postRegister(RegisterRequest request);

  /// Şirket kur + admin kaydı
  Future<RegisterAdminResponse?> postRegisterAdmin(RegisterAdminRequest request);

  /// Çıkış yap — Bearer token AppDio interceptor tarafından eklenir.
  Future<bool> postLogout();
}
