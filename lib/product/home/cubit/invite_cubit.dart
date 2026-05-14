import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../model/invite_model.dart';
import '../service/invite_service.dart';

part 'invite_state.dart';

class InviteCubit extends Cubit<InviteState> {
  final InviteService service;

  InviteCubit()
      : service = InviteService(AppDio.create()),
        super(const InviteState());

  Future<void> sendInvite({
    required String email,
    required String gsmNumber,
  }) async {
    emit(state.copyWith(status: InviteStatus.loading));

    final response = await service.sendInvite(
      InviteRequest(email: email, gsmNumber: gsmNumber),
    );

    if (response == null) {
      emit(state.copyWith(
        status: InviteStatus.error,
        errorMessage: 'Sunucuya bağlanılamadı.',
      ));
      return;
    }

    if (response.success) {
      AppLogger.i('[InviteCubit] Davet gönderildi');
      emit(state.copyWith(
        status: InviteStatus.success,
        inviteData: response.data,
      ));
    } else {
      AppLogger.w('[InviteCubit] Hata: ${response.message}');
      emit(state.copyWith(
        status: InviteStatus.error,
        errorMessage: response.message ?? 'Davet gönderilemedi.',
      ));
    }
  }

  void reset() => emit(const InviteState());
}
