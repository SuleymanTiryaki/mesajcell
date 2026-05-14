import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../model/channel_model.dart';
import '../service/channel_service.dart';

part 'public_channel_list_state.dart';

class PublicChannelListCubit extends Cubit<PublicChannelListState> {
  final ChannelService service;

  PublicChannelListCubit()
      : service = ChannelService(AppDio.create()),
        super(const PublicChannelListState());

  Future<void> fetchPublicChannels() async {
    emit(state.copyWith(status: PublicChannelListStatus.loading));

    final response = await service.getPublicChannels();

    if (response == null) {
      emit(state.copyWith(
        status: PublicChannelListStatus.error,
        errorMessage: 'Sunucuya bağlanılamadı.',
      ));
      return;
    }

    if (response.success) {
      AppLogger.i(
          '[PublicChannelListCubit] ${response.channels.length} açık kanal yüklendi');
      emit(state.copyWith(
        status: PublicChannelListStatus.success,
        channels: response.channels,
      ));
    } else {
      emit(state.copyWith(
        status: PublicChannelListStatus.error,
        errorMessage: 'Açık kanallar yüklenemedi.',
      ));
    }
  }
}
