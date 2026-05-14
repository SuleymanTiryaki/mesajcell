import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../model/channel_model.dart';
import '../service/channel_service.dart';

part 'create_channel_state.dart';

class CreateChannelCubit extends Cubit<CreateChannelState> {
  final ChannelService service;

  CreateChannelCubit()
      : service = ChannelService(AppDio.create()),
        super(const CreateChannelState());

  Future<void> createChannel({
    required String name,
    required String description,
    required ChannelType type,
    String? iconUrl,
  }) async {
    emit(state.copyWith(status: CreateChannelStatus.loading));

    try {
      final response = await service.createChannel(
        CreateChannelRequest(
          name: name,
          description: description,
          type: type,
          iconUrl: iconUrl?.isEmpty ?? true ? null : iconUrl,
        ),
      );

      if (response == null) {
        emit(state.copyWith(
          status: CreateChannelStatus.error,
          errorMessage: 'Sunucuya bağlanılamadı.',
        ));
        return;
      }

      if (response.success) {
        AppLogger.i('[CreateChannelCubit] Kanal oluşturuldu: ${response.channel?.id}');
        emit(state.copyWith(
          status: CreateChannelStatus.success,
          channel: response.channel,
        ));
      } else {
        AppLogger.w('[CreateChannelCubit] Hata: ${response.message}');
        emit(state.copyWith(
          status: CreateChannelStatus.error,
          errorMessage: response.message ?? 'Kanal oluşturulamadı.',
        ));
      }
    } catch (e, st) {
      AppLogger.e('[CreateChannelCubit] hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: CreateChannelStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void clearError() => emit(state.copyWith(status: CreateChannelStatus.initial));
}
