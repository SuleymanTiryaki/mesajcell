import '../../../features/core/app_session.dart';

class MessageModel {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String content;
  final bool isDeleted;
  final bool isPinned;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.isDeleted,
    required this.isPinned,
    required this.createdAt,
  });

  bool get isMe => senderId == AppSession.instance.userId;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String? ?? '',
        channelId: json['channel_id'] as String? ?? '',
        senderId: json['sender_id'] as String? ?? '',
        senderName: json['sender_name'] as String? ?? '',
        content: json['content'] as String? ?? '',
        isDeleted: json['is_deleted'] as bool? ?? false,
        isPinned: json['is_pinned'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

class GetMessagesResponse {
  final bool success;
  final List<MessageModel> messages;

  const GetMessagesResponse({required this.success, required this.messages});

  factory GetMessagesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return GetMessagesResponse(
      success: json['success'] as bool? ?? false,
      messages: data
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SendMessageResponse {
  final bool success;
  final MessageModel? message;

  const SendMessageResponse({required this.success, this.message});

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return SendMessageResponse(
      success: json['success'] as bool? ?? false,
      message: data != null ? MessageModel.fromJson(data) : null,
    );
  }
}
