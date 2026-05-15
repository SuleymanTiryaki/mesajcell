import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'app_logger.dart';
import 'app_session.dart';

/// Global Socket.io bağlantısı — singleton.
/// MainShell açılınca connect(), kapanınca disconnect() çağrılır.
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  static const String _baseUrl = 'https://coder-nights.onrender.com';

  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  // ─── Gelen event stream'leri ──────────────────────────────────────────────

  final _messageNew =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageEdit =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageDelete =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typing =
      StreamController<Map<String, dynamic>>.broadcast();
  final _status =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onMessageNew => _messageNew.stream;
  Stream<Map<String, dynamic>> get onMessageEdit => _messageEdit.stream;
  Stream<Map<String, dynamic>> get onMessageDelete => _messageDelete.stream;
  Stream<Map<String, dynamic>> get onTyping => _typing.stream;
  Stream<Map<String, dynamic>> get onStatus => _status.stream;

  // ─── Bağlantı ─────────────────────────────────────────────────────────────

  void connect() {
    final token = AppSession.instance.accessToken;
    if (token == null || token.isEmpty) {
      AppLogger.w('[Socket] Token yok, bağlantı yapılmadı.');
      return;
    }
    if (isConnected) return;

    _socket = io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );

    _socket!
      ..onConnect((_) => AppLogger.i('[Socket] Bağlandı'))
      ..onDisconnect((_) => AppLogger.w('[Socket] Bağlantı kesildi'))
      ..onConnectError((e) => AppLogger.e('[Socket] Bağlantı hatası: $e'))
      ..on('message:new', _dispatch(_messageNew))
      ..on('message:edit', _dispatch(_messageEdit))
      ..on('message:delete', _dispatch(_messageDelete))
      ..on('user:typing', _dispatch(_typing))
      ..on('user:status', _dispatch(_status));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    AppLogger.i('[Socket] Bağlantı kapatıldı');
  }

  // ─── Gönderilen eventler ─────────────────────────────────────────────────

  void sendMessage(String channelId, String content, {String? replyToMessageId}) =>
      _emit('message:send', {
        'channel_id': channelId,
        'content': content,
        'message_type': 'TEXT',
        if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
      });

  void editMessage(String messageId, String channelId, String content) =>
      _emit('message:edit', {
        'id': messageId,
        'channel_id': channelId,
        'content': content,
      });

  void deleteMessage(String messageId, String channelId) =>
      _emit('message:delete', {
        'id': messageId,
        'channel_id': channelId,
      });

  void sendFileMessage({
    required String channelId,
    required String fileName,
    required int fileSize,
    required String mimeType,
    String? fileUrl,
  }) {
    final messageType = mimeType.startsWith('image') ? 'IMAGE' : 'FILE';
    _emit('message:send', {
      'channel_id': channelId,
      'content': fileName,
      'message_type': messageType,
      'attachment': {
        'file_name': fileName,
        'file_size': fileSize,
        'mime_type': mimeType,
        if (fileUrl != null && fileUrl.isNotEmpty) 'file_url': fileUrl,
        'thumbnail_url': null,
      },
    });
  }

  void sendTyping(String channelId, {required bool isTyping}) =>
      _emit('user:typing', {'channel_id': channelId, 'is_typing': isTyping});

  void sendStatus(String presenceStatus) =>
      _emit('user:status', {'presence_status': presenceStatus});

  void sendReadReceipt(String channelId, String messageId) =>
      _emit('read:receipt', {'channel_id': channelId, 'message_id': messageId});

  void joinChannel(String channelId) =>
      _emit('channel:join', {'channel_id': channelId});

  // ─── Yardımcılar ─────────────────────────────────────────────────────────

  void _emit(String event, Map<String, dynamic> data) {
    if (!isConnected) {
      AppLogger.w('[Socket] Bağlı değil — event gönderilemedi: $event');
      return;
    }
    _socket!.emit(event, data);
    AppLogger.d('[Socket] emit $event → $data');
  }

  /// Socket.io data parametresi dynamic gelir; Map'e cast edip stream'e yazar.
  void Function(dynamic) _dispatch(
      StreamController<Map<String, dynamic>> ctrl) {
    return (data) {
      try {
        final map = (data as Map?)?.cast<String, dynamic>() ?? {};
        AppLogger.d('[Socket] ← ${ctrl.hashCode} $map');
        ctrl.add(map);
      } catch (e) {
        AppLogger.e('[Socket] dispatch hata: $e');
      }
    };
  }
}
