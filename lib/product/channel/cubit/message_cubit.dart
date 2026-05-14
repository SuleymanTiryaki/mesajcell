import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../model/channel_message_model.dart';
import '../service/channel_service.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final String channelId;
  final ChannelService _service;

  MessageCubit({required this.channelId})
      : _service = ChannelService(AppDio.create()),
        super(const MessageState());

  Future<void> fetchMessages() async {
    emit(state.copyWith(status: MessageStatus.loading));
    try {
      final response = await _service.getMessages(channelId);
      final messages = response?.messages ?? [];
      AppLogger.i('[MessageCubit] ${messages.length} mesaj yüklendi');
      emit(state.copyWith(status: MessageStatus.success, messages: messages));
    } catch (e, st) {
      AppLogger.e('[MessageCubit] fetchMessages hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: MessageStatus.error,
        errorMessage: 'Mesajlar yüklenemedi.',
      ));
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    emit(state.copyWith(sending: true));
    try {
      final response =
          await _service.sendMessage(channelId, content.trim());
      if (response?.success == true && response?.message != null) {
        emit(state.copyWith(
          messages: [...state.messages, response!.message!],
          sending: false,
        ));
      } else {
        emit(state.copyWith(sending: false));
      }
    } catch (e, st) {
      AppLogger.e('[MessageCubit] sendMessage hata', error: e, stackTrace: st);
      emit(state.copyWith(sending: false));
    }
  }
}
