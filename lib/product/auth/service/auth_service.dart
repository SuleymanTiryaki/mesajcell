import 'package:dio/dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/base_dio_service.dart';
import '../model/login_model.dart';
import '../model/otp_model.dart';
import '../model/register_model.dart';
import '../model/register_admin_model.dart';
import 'IAuth_service.dart';

class AuthService extends IAuthService {
  AuthService(super.dio);

  @override
  Future<LoginResponse?> postLogin(LoginRequest request) async {
    try {
      AppLogger.d('[AuthService] postLogin → ${request.toJson()}');
      final response = await dio.post(
        IAuthService.loginPath,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<OtpResponse?> postVerifyOtp(OtpRequest request) async {
    try {
      AppLogger.d('[AuthService] postVerifyOtp → ${request.toJson()}');
      final response = await dio.post(
        IAuthService.verifyOtpPath,
        data: request.toJson(),
      );
      return OtpResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<bool> postResendOtp(String phoneNumber) async {
    try {
      AppLogger.d('[AuthService] postResendOtp → $phoneNumber');
      await dio.post(
        IAuthService.resendOtpPath,
        data: {'phone_number': phoneNumber},
      );
      return true;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    }
  }

  @override
  Future<RegisterResponse?> postRegister(RegisterRequest request) async {
    try {
      AppLogger.d('[AuthService] postRegister → ${request.toJson()}');
      final response = await dio.post(
        IAuthService.registerPath,
        data: request.toJson(),
      );
      return RegisterResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<RegisterAdminResponse?> postRegisterAdmin(
      RegisterAdminRequest request) async {
    try {
      AppLogger.d('[AuthService] postRegisterAdmin → ${request.toJson()}');
      final response = await dio.post(
        IAuthService.registerAdminPath,
        data: request.toJson(),
      );
      return RegisterAdminResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<bool> postLogout() async {
    try {
      AppLogger.d('[AuthService] postLogout');
      await dio.post(IAuthService.logoutPath);
      return true;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    }
  }
}
