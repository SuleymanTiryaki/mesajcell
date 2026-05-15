import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/socket_service.dart';
import '../model/channel_message_model.dart';
import '../service/channel_service.dart';
import '../../notification/service/notification_service.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final String channelId;
  final ChannelService _service;
  final NotificationService _notifService;

  String? _dmTargetUserId;

  /// DM kanalında hedef kullanıcıyı ayarlar.
  /// [ChannelView] içinde üyeler yüklendiğinde çağrılır.
  void setDmTargetUserId(String id) => _dmTargetUserId = id;

  StreamSubscription<Map<String, dynamic>>? _newSub;
  StreamSubscription<Map<String, dynamic>>? _editSub;
  StreamSubscription<Map<String, dynamic>>? _deleteSub;

  MessageCubit({required this.channelId})
      : _service = ChannelService(AppDio.create()),
        _notifService = NotificationService(AppDio.create()),
        super(const MessageState()) {
    _subscribeToSocket();
  }

  void _subscribeToSocket() {
    _newSub = SocketService.instance.onMessageNew.listen((data) {
      if (data['channel_id'] != channelId) return;
      final msg = MessageModel.fromJson(data);
      if (state.messages.any((m) => m.id == msg.id)) return;
      if (!isClosed) emit(state.copyWith(messages: [...state.messages, msg]));
    });

    _editSub = SocketService.instance.onMessageEdit.listen((data) {
      if (data['channel_id'] != channelId) return;
      final id = data['id'] as String?;
      final content = data['content'] as String?;
      if (id == null || content == null) return;
      final updated = state.messages
          .map((m) => m.id == id
              ? m.copyWith(content: content, isEdited: true)
              : m)
          .toList();
      if (!isClosed) emit(state.copyWith(messages: updated));
    });

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

  // ─── Fetch ────────────────────────────────────────────────────────────────

  Future<void> fetchMessages() async {
    emit(state.copyWith(status: MessageStatus.loading, currentPage: 1, hasMore: true));
    try {
      final response = await _service.getMessages(channelId, page: 1);
      final messages = response?.messages ?? [];
      AppLogger.i('[MessageCubit] ${messages.length} mesaj yüklendi');
      emit(state.copyWith(
        status: MessageStatus.success,
        messages: messages,
        hasMore: messages.length >= 20,
      ));
    } catch (e, st) {
      AppLogger.e('[MessageCubit] fetchMessages hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: MessageStatus.error,
        errorMessage: 'Mesajlar yüklenemedi.',
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    emit(state.copyWith(loadingMore: true));
    final nextPage = state.currentPage + 1;
    try {
      final response = await _service.getMessages(channelId, page: nextPage);
      final newMsgs = response?.messages ?? [];
      if (newMsgs.isEmpty) {
        emit(state.copyWith(loadingMore: false, hasMore: false));
      } else {
        emit(state.copyWith(
          messages: [...newMsgs, ...state.messages],
          currentPage: nextPage,
          loadingMore: false,
          hasMore: newMsgs.length >= 20,
        ));
      }
    } catch (e, st) {
      AppLogger.e('[MessageCubit] loadMore hata', error: e, stackTrace: st);
      emit(state.copyWith(loadingMore: false));
    }
  }

  // ─── Send ─────────────────────────────────────────────────────────────────

  Future<void> sendMessage(String content, {String? replyToMessageId}) async {
    if (content.trim().isEmpty) return;
    final trimmed = content.trim();
    if (SocketService.instance.isConnected) {
      SocketService.instance.sendMessage(channelId, trimmed, replyToMessageId: replyToMessageId);
      // DM kanalında karşı tarafa bildirim gönder
      if (_dmTargetUserId != null) {
        _notifService.createNotification(
          userId: _dmTargetUserId!,
          type: 'MESSAGE',
          referenceId: channelId,
        );
      }
    } else {
      emit(state.copyWith(sending: true));
      try {
        final response = await _service.sendMessage(channelId, trimmed);
        if (response?.success == true && response?.message != null) {
          final msg = response!.message!;
          // DM kanalında karşı tarafa bildirim gönder
          if (_dmTargetUserId != null) {
            _notifService.createNotification(
              userId: _dmTargetUserId!,
              type: 'MESSAGE',
              referenceId: msg.id,
            );
          }
          if (!state.messages.any((m) => m.id == msg.id)) {
            emit(state.copyWith(messages: [...state.messages, msg], sending: false));
          } else {
            emit(state.copyWith(sending: false));
          }
        } else {
          emit(state.copyWith(sending: false));
        }
      } catch (e, st) {
        AppLogger.e('[MessageCubit] sendMessage REST hata', error: e, stackTrace: st);
        emit(state.copyWith(sending: false));
      }
    }
  }

  Future<void> sendFileMessage({
    required String fileName,
    required int fileSize,
    required String mimeType,
    String? fileUrl,
  }) async {
    SocketService.instance.sendFileMessage(
      channelId: channelId,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      fileUrl: fileUrl,
    );
  }

  // ─── Edit ─────────────────────────────────────────────────────────────────

  Future<void> editMessage(String msgId, String content) async {
    // Optimistic update
    final updated = state.messages
        .map((m) => m.id == msgId
            ? m.copyWith(content: content, isEdited: true)
            : m)
        .toList();
    if (!isClosed) emit(state.copyWith(messages: updated));
    if (SocketService.instance.isConnected) {
      SocketService.instance.editMessage(msgId, channelId, content);
    } else {
      await _service.editMessage(msgId, content);
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteMessage(String msgId) async {
    // Optimistic update
    final updated = state.messages
        .map((m) => m.id == msgId
            ? m.copyWith(content: 'Bu mesaj silindi', isDeleted: true)
            : m)
        .toList();
    if (!isClosed) emit(state.copyWith(messages: updated));
    if (SocketService.instance.isConnected) {
      SocketService.instance.deleteMessage(msgId, channelId);
    } else {
      await _service.deleteMessage(msgId);
    }
  }

  // ─── React ────────────────────────────────────────────────────────────────

  Future<void> addReaction(String msgId, String emoji) async {
    // Optimistic: find or add reaction
    final updated = state.messages.map((m) {
      if (m.id != msgId) return m;
      final existing = m.reactions.where((r) => r.emoji == emoji).firstOrNull;
      final newReactions = existing != null
          ? m.reactions
              .map((r) => r.emoji == emoji ? Reaction(emoji: emoji, count: r.count + 1) : r)
              .toList()
          : [...m.reactions, Reaction(emoji: emoji, count: 1)];
      return m.copyWith(reactions: newReactions);
    }).toList();
    if (!isClosed) emit(state.copyWith(messages: updated));
    await _service.addReaction(msgId, emoji, channelId);
  }

  // ─── Pin ──────────────────────────────────────────────────────────────────

  Future<bool> pinMessage(String msgId) async {
    final updated = state.messages
        .map((m) => m.id == msgId ? m.copyWith(isPinned: true) : m)
        .toList();
    if (!isClosed) emit(state.copyWith(messages: updated));
    final ok = await _service.pinMessage(channelId, msgId);
    if (ok) await fetchPinnedMessages();
    return ok;
  }

  Future<void> fetchPinnedMessages() async {
    if (!isClosed) emit(state.copyWith(loadingPinned: true));
    final pinned = await _service.getPinnedMessages(channelId);
    if (!isClosed) emit(state.copyWith(pinnedMessages: pinned, loadingPinned: false));
  }

  @override
  Future<void> close() {
    _newSub?.cancel();
    _editSub?.cancel();
    _deleteSub?.cancel();
    return super.close();
  }
}
