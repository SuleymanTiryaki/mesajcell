import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../model/invite_info_model.dart';

part 'invite_info_state.dart';

class InviteInfoCubit extends Cubit<InviteInfoState> {
  InviteInfoCubit() : super(const InviteInfoState());

  Future<void> fetchFromLink(String link) async {
    final trimmed = link.trim();
    final uri = Uri.tryParse(trimmed);
    final token = uri?.queryParameters['token'];

    if (token == null || token.isEmpty) {
      emit(state.copyWith(
        status: InviteInfoStatus.error,
        errorMessage: 'Geçersiz davet linki. Lütfen linki doğru yapıştırın.',
      ));
      return;
    }

    emit(state.copyWith(status: InviteInfoStatus.loading));

    try {
      final dio = AppDio.create();
      final response = await dio.get(
        '/api/v1/org/invite-info',
        queryParameters: {'token': token},
      );

      final info = InviteInfoResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (info.success && info.orgName != null) {
        AppLogger.i('[InviteInfoCubit] Org bilgisi alındı: ${info.orgName}');
        emit(state.copyWith(
          status: InviteInfoStatus.success,
          orgName: info.orgName,
          inviteToken: token,
        ));
      } else {
        emit(state.copyWith(
          status: InviteInfoStatus.error,
          errorMessage: info.message ?? 'Davet linki geçersiz veya süresi dolmuş.',
        ));
      }
    } catch (e, st) {
      AppLogger.e('[InviteInfoCubit] fetchFromLink hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: InviteInfoStatus.error,
        errorMessage: 'Davet linki doğrulanamadı. Lütfen tekrar deneyin.',
      ));
    }
  }

  void reset() => emit(const InviteInfoState());
}
