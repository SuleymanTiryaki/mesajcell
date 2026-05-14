import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_logger.dart';
import '../../auth/model/otp_model.dart';
import '../../auth/model/register_admin_model.dart';
import '../../auth/service/IAuth_service.dart'; // ignore: file_names

part 'register_admin_state.dart';

class RegisterAdminCubit extends Cubit<RegisterAdminState> {
  final IAuthService service;

  final TextEditingController gsmController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController orgNameController = TextEditingController();
  final TextEditingController orgDomainController = TextEditingController();
  final TextEditingController orgLogoController = TextEditingController();

  RegisterAdminCubit({required this.service})
      : super(const RegisterAdminState());

  @override
  Future<void> close() {
    gsmController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    orgNameController.dispose();
    orgDomainController.dispose();
    orgLogoController.dispose();
    return super.close();
  }

  Future<void> registerAdmin() async {
    final gsm = gsmController.text.trim();
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final orgName = orgNameController.text.trim();
    final orgDomain = orgDomainController.text.trim();
    final orgLogo = orgLogoController.text.trim();

    if (gsm.isEmpty || gsm.length < 10) {
      emit(state.copyWith(
        status: RegisterAdminStatus.error,
        errorMessage: 'Geçerli bir GSM numarası girin.',
      ));
      return;
    }
    if (fullName.isEmpty) {
      emit(state.copyWith(
        status: RegisterAdminStatus.error,
        errorMessage: 'Ad Soyad boş bırakılamaz.',
      ));
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      emit(state.copyWith(
        status: RegisterAdminStatus.error,
        errorMessage: 'Geçerli bir e-posta adresi girin.',
      ));
      return;
    }
    if (password.length < 6) {
      emit(state.copyWith(
        status: RegisterAdminStatus.error,
        errorMessage: 'Şifre en az 6 karakter olmalıdır.',
      ));
      return;
    }
    if (orgName.isEmpty) {
      emit(state.copyWith(
        status: RegisterAdminStatus.error,
        errorMessage: 'Şirket adı boş bırakılamaz.',
      ));
      return;
    }
    if (orgDomain.isEmpty) {
      emit(state.copyWith(
        status: RegisterAdminStatus.error,
        errorMessage: 'Şirket domain boş bırakılamaz.',
      ));
      return;
    }

    emit(state.copyWith(status: RegisterAdminStatus.loading));

    try {
      final response = await service.postRegisterAdmin(
        RegisterAdminRequest(
          gsmNumber: gsm,
          fullName: fullName,
          email: email,
          password: password,
          orgName: orgName,
          orgDomain: orgDomain,
          orgLogo: orgLogo.isNotEmpty ? orgLogo : null,
        ),
      );

      if (response?.success == true) {
        AppLogger.i('[RegisterAdminCubit] Şirket kuruldu → OTP ekranına yönlendir');
        emit(state.copyWith(status: RegisterAdminStatus.success));
      } else {
        AppLogger.w('[RegisterAdminCubit] Kayıt başarısız: ${response?.message}');
        emit(state.copyWith(
          status: RegisterAdminStatus.error,
          errorMessage: response?.message ?? 'Kayıt başarısız.',
        ));
      }
    } catch (e, st) {
      AppLogger.e('[RegisterAdminCubit] registerAdmin hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: RegisterAdminStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void clearError() => emit(state.clearError());
}
