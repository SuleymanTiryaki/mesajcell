import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/app_session.dart';
import '../../home/model/me_model.dart';
import '../../home/service/home_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final HomeService _service;

  SettingsCubit()
      : _service = HomeService(AppDio.create()),
        super(const SettingsState());

  Future<void> loadMe() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final me = await _service.getMe();
    if (me == null) {
      emit(state.copyWith(
          status: SettingsStatus.error, errorMessage: 'Profil yüklenemedi.'));
      return;
    }
    emit(state.copyWith(status: SettingsStatus.success, me: me));
  }

  Future<bool> updateMe({
    required String fullName,
    required String email,
    String? profilePhotoUrl,
    String? presenceStatus,
  }) async {
    emit(state.copyWith(saving: true, errorMessage: null));
    try {
      final ok = await _service.updateMe(
        fullName: fullName,
        email: email,
        profilePhotoUrl:
            profilePhotoUrl?.isNotEmpty == true ? profilePhotoUrl : null,
        presenceStatus: presenceStatus,
      );
      if (ok) {
        // AppSession'da adı güncelle
        if (AppSession.instance.accessToken != null) {
          await AppSession.instance.setTokens(
            accessToken: AppSession.instance.accessToken!,
            fullName: fullName,
          );
        }
        // Yerel state'i güncelle
        final updated = state.me?.copyWith(
          fullName: fullName,
          email: email,
          profilePhotoUrl: profilePhotoUrl,
          presenceStatus: presenceStatus,
        );
        emit(state.copyWith(saving: false, me: updated));
      } else {
        emit(state.copyWith(
            saving: false, errorMessage: 'Güncelleme başarısız.'));
      }
      return ok;
    } catch (e, st) {
      AppLogger.e('[SettingsCubit] updateMe', error: e, stackTrace: st);
      emit(state.copyWith(
          saving: false, errorMessage: 'Bir hata oluştu.'));
      return false;
    }
  }
}
