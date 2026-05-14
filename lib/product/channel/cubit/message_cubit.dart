import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/socket_service.dart';
import '../model/channel_message_model.dart';
import '../service/channel_service.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final String channelId;
  final ChannelService _service;

  StreamSubscription<Map<String, dynamic>>? _newSub;
  StreamSubscription<Map<String, dynamic>>? _editSub;
  StreamSubscription<Map<String, dynamic>>? _deleteSub;

  MessageCubit({required this.channelId})
      : _service = ChannelService(AppDio.create()),
        super(const MessageState()) {
    _subscribeToSocket();
  }

  void _subscribeToSocket() {
    // message:new → bu kanala aitse listeye ekle (dedup)
    _newSub = SocketService.instance.onMessageNew.listen((data) {
      if (data['channel_id'] != channelId) return;
      final msg = MessageModel.fromJson(data);
      if (state.messages.any((m) => m.id == msg.id)) return;
      if (!isClosed) {
        emit(state.copyWith(messages: [...state.messages, msg]));
      }
    });

    // message:edit → içeriği güncelle
    _editSub = SocketService.instance.onMessageEdit.listen((data) {
      if (data['channel_id'] != channelId) return;
      final id = data['id'] as String?;
      final content = data['content'] as String?;
      if (id == null || content == null) return;
      final updated = state.messages
          .map((m) => m.id == id ? m.copyWith(content: content) : m)
          .toList();
      if (!isClosed) emit(state.copyWith(messages: updated));
    });

    // message:delete → içeriği 'Bu mesaj silindi' yap
    _deleteSub = SocketService.instance.onMessageDelete.listen((data) {
      if (data['channel_id'] != channelId) return;
      final id = data['id'] as String?;
      if (id == null) return;
      final updated = state.messages
          .map((m) => m.id == id
              ? m.copyWith(content: 'Bu mesaj silindi', isDeleted: true)
              : m)
          .toList();
      if (!isClosed) emit(state.copyWith(messages: updated));
    });
  }

  // ─── REST ─────────────────────────────────────────────────────────────────

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

  // ─── Gönder ───────────────────────────────────────────────────────────────

  /// Socket bağlıysa WebSocket üzerinden gönderir; değilse REST'e düşer.
  /// message:new event'i listeye ekler — REST yanıtında da ekler (fallback).
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    final trimmed = content.trim();

    if (SocketService.instance.isConnected) {
      SocketService.instance.sendMessage(channelId, trimmed);
      // message:new event'i _newSub üzerinden listeye ekleyecek
    } else {
      // Socket bağlı değilse REST fallback
      emit(state.copyWith(sending: true));
      try {
        final response = await _service.sendMessage(channelId, trimmed);
        if (response?.success == true && response?.message != null) {
          final msg = response!.message!;
          if (!state.messages.any((m) => m.id == msg.id)) {
            emit(state.copyWith(
              messages: [...state.messages, msg],
              sending: false,
            ));
          } else {
            emit(state.copyWith(sending: false));
          }
        } else {
          emit(state.copyWith(sending: false));
        }
      } catch (e, st) {
        AppLogger.e('[MessageCubit] sendMessage REST hata',
            error: e, stackTrace: st);
        emit(state.copyWith(sending: false));
      }
    }
  }

  @override
  Future<void> close() {
    _newSub?.cancel();
    _editSub?.cancel();
    _deleteSub?.cancel();
    return super.close();
  }
}
