import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../model/channel_model.dart';
import '../service/channel_service.dart';

part 'channel_list_state.dart';

class ChannelListCubit extends Cubit<ChannelListState> {
  final ChannelService service;

  ChannelListCubit()
      : service = ChannelService(AppDio.create()),
        super(const ChannelListState());

  Future<void> fetchChannels() async {
    emit(state.copyWith(status: ChannelListStatus.loading));

    final response = await service.getChannels();

    if (response == null) {
      emit(state.copyWith(
        status: ChannelListStatus.error,
        errorMessage: 'Sunucuya bağlanılamadı.',
      ));
      return;
    }

    if (response.success) {
      AppLogger.i(
          '[ChannelListCubit] ${response.channels.length} kanal yüklendi');
      emit(state.copyWith(
        status: ChannelListStatus.success,
        channels: response.channels,
      ));
    } else {
      emit(state.copyWith(
        status: ChannelListStatus.error,
        errorMessage: 'Kanallar yüklenemedi.',
      ));
    }
  }
}
