import 'dart:io';
import 'package:dio/dio.dart';
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
      final response = await dio.post(
        IAuthService.loginPath,
        data: request.toJson(),
      );
      if (response.statusCode == HttpStatus.ok) {
        return LoginResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      throw BaseDioService.service.handleDioError(e);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OtpResponse?> postVerifyOtp(OtpRequest request) async {
    try {
      final response = await dio.post(
        IAuthService.verifyOtpPath,
        data: request.toJson(),
      );
      if (response.statusCode == HttpStatus.ok) {
        return OtpResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      throw BaseDioService.service.handleDioError(e);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> postResendOtp(String phoneNumber) async {
    try {
      final response = await dio.post(
        IAuthService.resendOtpPath,
        data: {'phoneNumber': phoneNumber},
      );
      return response.statusCode == HttpStatus.ok;
    } on DioException catch (e) {
      throw BaseDioService.service.handleDioError(e);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<RegisterResponse?> postRegister(RegisterRequest request) async {
    try {
      final response = await dio.post(
        IAuthService.registerPath,
        data: request.toJson(),
      );
      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == 201) {
        return RegisterResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      throw BaseDioService.service.handleDioError(e);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RegisterAdminResponse?> postRegisterAdmin(
      RegisterAdminRequest request) async {
    try {
      final response = await dio.post(
        IAuthService.registerAdminPath,
        data: request.toJson(),
      );
      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == 201) {
        return RegisterAdminResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      throw BaseDioService.service.handleDioError(e);
    } catch (_) {
      return null;
    }
  }
}
