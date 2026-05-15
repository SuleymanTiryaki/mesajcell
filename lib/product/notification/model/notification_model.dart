import 'package:flutter/material.dart';

// ─── NotificationModel ────────────────────────────────────────────────────────

class NotificationModel {
  final String id;
  final String userId;
  final String type; // 'MENTION', 'CHANNEL_INVITE', 'MESSAGE'
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;
  final String? senderName;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
    this.senderName,
  });

  String get displayText {
    switch (type) {
      case 'MENTION':
        return senderName != null ? '$senderName seni etiketledi' : 'Seni etiketledi';
      case 'CHANNEL_INVITE':
        return senderName != null ? '$senderName bir kanala ekledi' : 'Bir kanala eklendiniz';
      case 'MESSAGE':
        return senderName != null ? '$senderName: Yeni mesaj' : 'Yeni mesaj var';
      default:
        return 'Yeni bildirim';
    }
  }

  IconData get icon {
    switch (type) {
      case 'MENTION':
        return Icons.alternate_email;
      case 'CHANNEL_INVITE':
        return Icons.group_add_outlined;
      case 'MESSAGE':
        return Icons.message_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        type: json['type']?.toString() ?? 'MESSAGE',
        referenceId: json['reference_id']?.toString(),
        isRead: _parseBool(json['is_read']),
        createdAt:
            DateTime.tryParse(json['created_at']?.toString() ?? '') ??
                DateTime.now(),
        senderName: json['sender_name']?.toString(),
      );

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    return false;
  }
}

// ─── Response ─────────────────────────────────────────────────────────────────

class GetNotificationsResponse {
  final bool success;
  final List<NotificationModel> notifications;

  const GetNotificationsResponse(
      {required this.success, required this.notifications});

  factory GetNotificationsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final data = raw is List ? raw : <dynamic>[];
    return GetNotificationsResponse(
      success: json['success'] as bool? ?? false,
      notifications: data
          .whereType<Map>()
          .map((e) =>
              NotificationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
