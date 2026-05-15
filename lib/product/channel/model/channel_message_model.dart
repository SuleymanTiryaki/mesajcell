import '../../../features/core/app_session.dart';

// ─── Reaction ─────────────────────────────────────────────────────────────────

class Reaction {
  final String emoji;
  final int count;

  const Reaction({required this.emoji, required this.count});

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        emoji: json['emoji']?.toString() ?? '',
        count: json['count'] as int? ?? 0,
      );
}

// ─── MessageAttachment ────────────────────────────────────────────────────────

class MessageAttachment {
  final String? id;
  final String fileName;
  final int fileSize; // bytes
  final String? mimeType;
  final String? fileUrl;
  final String? thumbnailUrl;

  const MessageAttachment({
    this.id,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
    this.fileUrl,
    this.thumbnailUrl,
  });

  bool get isImage => mimeType?.startsWith('image') ?? false;

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    final kb = fileSize / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      MessageAttachment(
        id: json['id']?.toString(),
        fileName: json['file_name']?.toString() ?? '',
        fileSize: json['file_size'] as int? ?? 0,
        mimeType: json['mime_type']?.toString(),
        fileUrl: json['file_url']?.toString(),
        thumbnailUrl: json['thumbnail_url']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'file_name': fileName,
        'file_size': fileSize,
        if (mimeType != null) 'mime_type': mimeType,
        if (fileUrl != null && fileUrl!.isNotEmpty) 'file_url': fileUrl,
        'thumbnail_url': thumbnailUrl,
      };
}

// ─── MessageModel ─────────────────────────────────────────────────────────────

class MessageModel {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String content;
  final String messageType; // 'TEXT', 'FILE', 'IMAGE'
  final bool isDeleted;
  final bool isEdited;
  final bool isPinned;
  final DateTime createdAt;
  final String? replyToMessageId;
  final List<Reaction> reactions;
  final List<MessageAttachment> attachments;

  const MessageModel({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.messageType = 'TEXT',
    required this.isDeleted,
    this.isEdited = false,
    required this.isPinned,
    required this.createdAt,
    this.replyToMessageId,
    this.reactions = const [],
    this.attachments = const [],
  });

  bool get isMe {
    final myId = AppSession.instance.userId;
    if (myId == null || myId.isEmpty) return false;
    return senderId == myId;
  }
  bool get isFile => messageType == 'FILE' || messageType == 'IMAGE';

  MessageModel copyWith({
    String? content,
    bool? isDeleted,
    bool? isEdited,
    bool? isPinned,
    List<Reaction>? reactions,
  }) =>
      MessageModel(
        id: id,
        channelId: channelId,
        senderId: senderId,
        senderName: senderName,
        content: content ?? this.content,
        messageType: messageType,
        isDeleted: isDeleted ?? this.isDeleted,
        isEdited: isEdited ?? this.isEdited,
        isPinned: isPinned ?? this.isPinned,
        createdAt: createdAt,
        replyToMessageId: replyToMessageId,
        reactions: reactions ?? this.reactions,
        attachments: attachments,
      );

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id']?.toString() ?? '',
        channelId: json['channel_id']?.toString() ?? '',
        senderId: json['sender_id']?.toString() ?? '',
        senderName: json['sender_name']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        messageType: json['message_type']?.toString() ?? 'TEXT',
        isDeleted: _parseBool(json['is_deleted']),
        isEdited: _parseBool(json['is_edited']),
        isPinned: _parseBool(json['is_pinned']),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
        replyToMessageId: json['reply_to_message_id']?.toString(),
        reactions: _parseReactions(json['reactions']),
        attachments: _parseAttachments(json['attachments']),
      );

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    return false;
  }

  static List<Reaction> _parseReactions(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Reaction.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  static List<MessageAttachment> _parseAttachments(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => MessageAttachment.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }
}

// ─── Responses ────────────────────────────────────────────────────────────────

class GetMessagesResponse {
  final bool success;
  final List<MessageModel> messages;

  const GetMessagesResponse({required this.success, required this.messages});

  factory GetMessagesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final data = raw is List ? raw : <dynamic>[];
    return GetMessagesResponse(
      success: json['success'] as bool? ?? false,
      messages: data
          .whereType<Map>()
          .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class SendMessageResponse {
  final bool success;
  final MessageModel? message;

  const SendMessageResponse({required this.success, this.message});

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final data = raw is Map ? Map<String, dynamic>.from(raw) : null;
    return SendMessageResponse(
      success: json['success'] as bool? ?? false,
      message: data != null ? MessageModel.fromJson(data) : null,
    );
  }
}

