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
      if (myId.isEmpty) return;
      final content = data['content'] as String? ?? '';
      if (content.contains(myId)) {
        // Mention geldi — unread badge artır
        emit(state.copyWith(
            unreadCount: state.unreadCount + 1,
            pendingMention: data['sender_name'] as String? ?? 'Biri'));
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
