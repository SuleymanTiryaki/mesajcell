part of 'notification_cubit.dart';

enum NotifStatus { initial, loading, success, error }

class NotificationState {
  final NotifStatus status;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String? errorMessage;
  final String? pendingMention; // senderName — snackbar için

  const NotificationState({
    this.status = NotifStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
    this.pendingMention,
  });

  NotificationState copyWith({
    NotifStatus? status,
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? errorMessage,
    String? pendingMention,
    bool clearMention = false,
  }) =>
      NotificationState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
        errorMessage: errorMessage ?? this.errorMessage,
        pendingMention:
            clearMention ? null : (pendingMention ?? this.pendingMention),
      );
}
