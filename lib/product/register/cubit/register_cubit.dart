import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_logger.dart';
import '../../auth/model/otp_model.dart';
import '../../auth/model/register_model.dart';
import '../../auth/service/IAuth_service.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final IAuthService service;

  final TextEditingController gsmController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController orgIdController = TextEditingController();

  RegisterCubit({required this.service}) : super(const RegisterState());

  @override
  Future<void> close() {
    gsmController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    orgIdController.dispose();
    return super.close();
  }

  Future<void> register() async {
    final gsm = gsmController.text.trim();
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final orgId = orgIdController.text.trim();

    if (gsm.isEmpty || gsm.length < 10) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'Geçerli bir GSM numarası girin.',
      ));
      return;
    }
    if (fullName.isEmpty) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'Ad Soyad boş bırakılamaz.',
      ));
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'Geçerli bir e-posta adresi girin.',
      ));
      return;
    }
    if (password.length < 6) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'Şifre en az 6 karakter olmalıdır.',
      ));
      return;
    }
    if (orgId.isEmpty) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'Organizasyon ID boş bırakılamaz.',
      ));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    try {
      final response = await service.postRegister(
        RegisterRequest(
          gsmNumber: gsm,
          fullName: fullName,
          email: email,
          password: password,
          orgId: orgId,
        ),
      );

      if (response?.success == true) {
        AppLogger.i('[RegisterCubit] Kayıt başarılı → OTP ekranına yönlendir');
        emit(state.copyWith(status: RegisterStatus.success));
      } else {
        AppLogger.w('[RegisterCubit] Kayıt başarısız: ${response?.message}');
        emit(state.copyWith(
          status: RegisterStatus.error,
          errorMessage: response?.message ?? 'Kayıt başarısız.',
        ));
      }
    } catch (e, st) {
      AppLogger.e('[RegisterCubit] register hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void clearError() => emit(state.clearError());
}
