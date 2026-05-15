import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/app_session.dart';
import '../../../features/core/socket_service.dart';
import '../model/notification_model.dart';
import '../service/notification_service.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _service;
  StreamSubscription<Map<String, dynamic>>? _socketSub;

  NotificationCubit()
      : _service = NotificationService(AppDio.create()),
        super(const NotificationState()) {
    _listenSocket();
  }

  void _listenSocket() {
    _socketSub = SocketService.instance.onMessageNew.listen((data) {
      final myId = AppSession.instance.userId ?? '';
      final myName = AppSession.instance.fullName ?? '';
      if (myId.isEmpty) return;

      final content = data['content'] as String? ?? '';
      final senderName = data['sender_name'] as String? ?? 'Biri';

      // Kendi mesajımızı sayma
      final senderId = data['sender_id']?.toString() ?? '';
      if (senderId == myId) return;

      // mentions[] array (sunucudan gelebilir) veya @fullName içerik kontrolü
      final mentions = data['mentions'];
      final mentionedById = mentions is List
          ? mentions.any((m) => m?.toString() == myId)
          : false;
      final mentionedByName = myName.isNotEmpty &&
          content.toLowerCase().contains('@${myName.toLowerCase()}');

      if (mentionedById || mentionedByName) {
        // Listeye yerel bildirim ekle (API çağrısına gerek kalmadan panelde görünsün)
        final localNotif = NotificationModel(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          userId: myId,
          type: 'MENTION',
          referenceId: data['channel_id']?.toString(),
          isRead: false,
          createdAt: DateTime.now(),
          senderName: senderName,
        );
        emit(state.copyWith(
          notifications: [localNotif, ...state.notifications],
          unreadCount: state.unreadCount + 1,
          pendingMention: senderName,
        ));
        // Backend'e de bildirim yaz (backend'e güvenme, explicit çağır)
        final messageId = data['id']?.toString();
        _service.createNotification(
          userId: myId,
          type: 'MENTION',
          referenceId: messageId,
        );
      }
    });
  }

  Future<void> fetchNotifications() async {
    emit(state.copyWith(status: NotifStatus.loading));
    final response = await _service.getNotifications();
    if (response == null) {
      emit(state.copyWith(
          status: NotifStatus.error, errorMessage: 'Bildirimler yüklenemedi.'));
      return;
    }
    final unread = response.notifications.where((n) => !n.isRead).length;
    emit(state.copyWith(
      status: NotifStatus.success,
      notifications: response.notifications,
      unreadCount: unread,
    ));
  }

  Future<void> markAllRead() async {
    await _service.markAllRead();
    final updated =
        state.notifications.map((n) => n.isRead ? n : _markRead(n)).toList();
    emit(state.copyWith(
        notifications: updated, unreadCount: 0, clearMention: true));
    AppLogger.i('[NotificationCubit] Tüm bildirimler okundu olarak işaretlendi');
  }

  void clearPendingMention() {
    emit(state.copyWith(clearMention: true));
  }

  NotificationModel _markRead(NotificationModel n) => NotificationModel(
        id: n.id,
        userId: n.userId,
        type: n.type,
        referenceId: n.referenceId,
        isRead: true,
        createdAt: n.createdAt,
      );

  @override
  Future<void> close() {
    _socketSub?.cancel();
    return super.close();
  }
}
