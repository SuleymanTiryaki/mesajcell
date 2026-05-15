import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/core/app_session.dart';
import '../../../features/core/socket_service.dart';
import '../../../features/utility/const/constant_color.dart';
import '../cubit/channel_members_cubit.dart';
import '../cubit/message_cubit.dart';
import '../model/channel_member_model.dart';
import '../model/channel_message_model.dart';
import '../model/channel_model.dart';

class ChannelView extends StatelessWidget {
  final ChannelModel channel;
  final bool embedded;
  final VoidCallback? onMenuTap;

  const ChannelView({
    super.key,
    required this.channel,
    this.embedded = false,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ChannelMembersCubit(channelId: channel.id)..fetchMembers(),
        ),
        BlocProvider(
          create: (_) =>
              MessageCubit(channelId: channel.id)..fetchMessages(),
        ),
      ],
      child: _ChannelViewBody(
        channel: channel,
        embedded: embedded,
        onMenuTap: onMenuTap,
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────────

class _ChannelViewBody extends StatefulWidget {
  final ChannelModel channel;
  final bool embedded;
  final VoidCallback? onMenuTap;

  const _ChannelViewBody({
    required this.channel,
    required this.embedded,
    this.onMenuTap,
  });

  @override
  State<_ChannelViewBody> createState() => _ChannelViewBodyState();
}

class _ChannelViewBodyState extends State<_ChannelViewBody> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingTimer;

  // Editing state
  String? _editingMessageId;
  String _editingOriginalContent = '';

  // Reply state
  MessageModel? _replyTo;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 60) {
      final cubit = context.read<MessageCubit>();
      if (!cubit.state.loadingMore && cubit.state.hasMore) {
        cubit.loadMore();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendReadReceipt(List<MessageModel> messages) {
    if (messages.isEmpty) return;
    SocketService.instance.sendReadReceipt(widget.channel.id, messages.last.id);
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _typingTimer?.cancel();
    SocketService.instance.sendTyping(widget.channel.id, isTyping: false);
    if (_editingMessageId != null) {
      final msgId = _editingMessageId!;
      setState(() {
        _editingMessageId = null;
        _editingOriginalContent = '';
      });
      context.read<MessageCubit>().editMessage(msgId, text);
    } else {
      final replyId = _replyTo?.id;
      setState(() => _replyTo = null);
      context.read<MessageCubit>().sendMessage(text, replyToMessageId: replyId);
    }
  }

  void _startEditing(MessageModel msg) {
    setState(() {
      _replyTo = null;
      _editingMessageId = msg.id;
      _editingOriginalContent = msg.content;
      _textController.text = msg.content;
      _textController.selection =
          TextSelection.collapsed(offset: msg.content.length);
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessageId = null;
      _editingOriginalContent = '';
    });
    _textController.clear();
  }

  void _startReply(MessageModel msg) {
    setState(() {
      _editingMessageId = null;
      _editingOriginalContent = '';
      _replyTo = msg;
    });
    _textController.clear();
  }

  void _cancelReply() {
    setState(() => _replyTo = null);
  }

  void _onTextChanged(String value) {
    SocketService.instance.sendTyping(widget.channel.id, isTyping: value.isNotEmpty);
    _typingTimer?.cancel();
    if (value.isNotEmpty) {
      _typingTimer = Timer(const Duration(seconds: 1), () {
        SocketService.instance.sendTyping(widget.channel.id, isTyping: false);
      });
    }
  }

  void _showMessageMenu(BuildContext ctx, MessageModel msg) {
    final isMe = msg.isMe;
    final isAdmin = AppSession.instance.isOrgAdmin ||
        ctx.read<ChannelMembersCubit>().state.isCurrentUserAdmin;
    final messageCubit = ctx.read<MessageCubit>();

    showModalBottomSheet(
      context: ctx,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Yanıtla — her zaman görünür
            ListTile(
              leading: const Icon(Icons.reply_outlined),
              title: const Text('Yanıtla'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _startReply(msg);
              },
            ),
            // Düzenle — sadece kendi mesajı, silinmemiş
            if (isMe && !msg.isDeleted)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Düzenle'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _startEditing(msg);
                },
              ),
            // Sil — kendi mesajı veya admin
            if ((isMe || isAdmin) && !msg.isDeleted)
              ListTile(
                leading:
                    Icon(Icons.delete_outline, color: Colors.red.shade400),
                title: Text('Sil',
                    style: TextStyle(color: Colors.red.shade400)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showDeleteConfirm(ctx, messageCubit, msg.id);
                },
              ),
            // Reaksiyon — silinmemiş mesajlar
            if (!msg.isDeleted)
              ListTile(
                leading: const Icon(Icons.emoji_emotions_outlined),
                title: const Text('Reaksiyon Ekle'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showEmojiPicker(ctx, messageCubit, msg);
                },
              ),
            // Sabitle — sadece admin, silinmemiş
            if (isAdmin && !msg.isDeleted)
              ListTile(
                leading: const Icon(Icons.push_pin_outlined),
                title: const Text('Sabitle'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  messageCubit.pinMessage(msg.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext ctx, MessageCubit cubit, String msgId) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('Mesajı Sil'),
        content: const Text('Bu mesajı silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dCtx);
              cubit.deleteMessage(msgId);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker(BuildContext ctx, MessageCubit cubit, MessageModel msg) {
    const emojis = ['👍', '❤️', '😂', '😮', '😢', '🎉'];
    showModalBottomSheet(
      context: ctx,
      builder: (emojiCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: emojis
                .map(
                  (e) => GestureDetector(
                    onTap: () {
                      Navigator.pop(emojiCtx);
                      cubit.addReaction(msg.id, e);
                    },
                    child: Text(e, style: const TextStyle(fontSize: 32)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final listeners = MultiBlocListener(
      listeners: [
        BlocListener<MessageCubit, MessageState>(
          listenWhen: (prev, curr) =>
              curr.messages.length > prev.messages.length &&
              curr.status == MessageStatus.success,
          listener: (ctx, st) {
            _scrollToBottom();
            _sendReadReceipt(st.messages);
          },
        ),
        BlocListener<MessageCubit, MessageState>(
          listenWhen: (prev, curr) =>
              prev.status != MessageStatus.success &&
              curr.status == MessageStatus.success,
          listener: (ctx, st) => _sendReadReceipt(st.messages),
        ),
        BlocListener<ChannelMembersCubit, ChannelMembersState>(
          listenWhen: (prev, curr) =>
              curr.lastActionMessage != null &&
              curr.lastActionMessage != prev.lastActionMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.lastActionMessage!)));
            context.read<ChannelMembersCubit>().clearActionMessage();
          },
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: _ChatArea(
              scrollController: _scrollController,
              onLongPress: (msg) => _showMessageMenu(context, msg),
            ),
          ),
          _TypingIndicator(),
        ],
      ),
    );

    final inputArea = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_editingMessageId != null)
          _EditingBanner(
            content: _editingOriginalContent,
            onCancel: _cancelEditing,
          ),
        if (_replyTo != null)
          _ReplyBanner(
            senderName: _replyTo!.senderName,
            content: _replyTo!.content,
            onCancel: _cancelReply,
          ),
        _MessageInput(
          controller: _textController,
          onSend: _send,
          onChanged: _onTextChanged,
        ),
      ],
    );

    if (widget.embedded) {
      return Column(
        children: [
          _EmbeddedHeader(channel: widget.channel),
          Expanded(child: listeners),
          inputArea,
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.channel.type == ChannelType.dm
              ? widget.channel.name
              : '# ${widget.channel.name}',
        ),
        titleSpacing: 0,
        leading: widget.onMenuTap != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuTap,
              )
            : null,
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.group_outlined),
              tooltip: 'Üyeler',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _MembersDrawer(channel: widget.channel),
      body: listeners,
      bottomNavigationBar: inputArea,
    );
  }
}

// ─── Embedded header (tablet) ─────────────────────────────────────────────────

class _EmbeddedHeader extends StatelessWidget {
  final ChannelModel channel;
  const _EmbeddedHeader({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            channel.type == ChannelType.dm
                ? channel.name
                : '# ${channel.name}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.group_outlined),
              tooltip: 'Üyeler',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat area ────────────────────────────────────────────────────────────────

class _ChatArea extends StatelessWidget {
  final ScrollController scrollController;
  final void Function(MessageModel) onLongPress;

  const _ChatArea({
    required this.scrollController,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state.status == MessageStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == MessageStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage ?? 'Hata oluştu.'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<MessageCubit>().fetchMessages(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        if (state.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz mesaj yok',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İlk mesajı göndererek sohbeti başlat!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: state.messages.length,
              itemBuilder: (context, i) {
                final msg = state.messages[i];
                final prev = i > 0 ? state.messages[i - 1] : null;
                final showSender = !msg.isMe && msg.senderId != prev?.senderId;
                final replyMsg = msg.replyToMessageId != null
                    ? state.messages
                        .where((m) => m.id == msg.replyToMessageId)
                        .firstOrNull
                    : null;
                return _MessageBubble(
                  message: msg,
                  showSender: showSender,
                  replyMessage: replyMsg,
                  onLongPress: () => onLongPress(msg),
                );
              },
            ),
            if (state.loadingMore)
              const Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Message bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final MessageModel? replyMessage;
  final bool showSender;
  final VoidCallback onLongPress;

  const _MessageBubble({
    required this.message,
    required this.showSender,
    required this.onLongPress,
    this.replyMessage,
  });

  String _formatTime(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final bubbleColor = isMe
        ? ConstColor.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor =
        isMe ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final timeColor = isMe
        ? Colors.white70
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onLongPress: message.isDeleted ? null : onLongPress,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMe ? 64 : 12,
          right: isMe ? 12 : 64,
          bottom: 4,
          top: showSender ? 8 : 2,
        ),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Yanıt önizlemesi
                    if (replyMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withAlpha(40)
                              : Theme.of(context).colorScheme.surface.withAlpha(180),
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(color: ConstColor.primary, width: 3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              replyMessage!.senderName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ConstColor.primary,
                              ),
                            ),
                            Text(
                              replyMessage!.isDeleted
                                  ? 'Bu mesaj silindi'
                                  : replyMessage!.content,
                              style: TextStyle(
                                fontSize: 11,
                                color: isMe ? Colors.white70 : ConstColor.grey600,
                                fontStyle: replyMessage!.isDeleted
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    if (showSender && !isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          message.senderName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ConstColor.primary,
                          ),
                        ),
                      ),
                    if (message.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.push_pin,
                                size: 12,
                                color: isMe ? Colors.white70 : ConstColor.primary),
                            const SizedBox(width: 4),
                            Text('Sabitlenmiş',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: isMe
                                        ? Colors.white70
                                        : ConstColor.primary)),
                          ],
                        ),
                      ),
                    message.isDeleted
                        ? Text(
                            'Bu mesaj silindi',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          )
                        : message.isFile
                            ? _FileAttachmentCard(
                                message: message,
                                isMe: isMe,
                                textColor: textColor,
                              )
                            : Text(message.content,
                                style: TextStyle(color: textColor)),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(fontSize: 10, color: timeColor),
                        ),
                        if (message.isEdited && !message.isDeleted) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(düzenlendi)',
                            style: TextStyle(fontSize: 9, color: timeColor),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Reactions
              if (message.reactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 4,
                    children: message.reactions
                        .map((r) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: Text('${r.emoji} ${r.count}',
                                  style: const TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Editing banner ───────────────────────────────────────────────────────────

class _EditingBanner extends StatelessWidget {
  final String content;
  final VoidCallback onCancel;
  const _EditingBanner({required this.content, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ConstColor.primary.withAlpha(15),
        border: Border(
          left: const BorderSide(color: ConstColor.primary, width: 3),
          top: BorderSide(
              color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, size: 16, color: ConstColor.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mesaj düzenleniyor',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ConstColor.primary,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(fontSize: 12, color: ConstColor.grey600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onCancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: ConstColor.grey500,
          ),
        ],
      ),
    );
  }
}

// ─── Reply banner ─────────────────────────────────────────────────────────────

class _ReplyBanner extends StatelessWidget {
  final String senderName;
  final String content;
  final VoidCallback onCancel;
  const _ReplyBanner({
    required this.senderName,
    required this.content,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          left: const BorderSide(color: ConstColor.primary, width: 3),
          top: BorderSide(
              color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply_outlined, size: 16, color: ConstColor.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ConstColor.primary,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(fontSize: 12, color: ConstColor.grey600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onCancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: ConstColor.grey500,
          ),
        ],
      ),
    );
  }
}

// ─── Typing indicator ─────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelMembersCubit, ChannelMembersState>(
      buildWhen: (prev, curr) => prev.typingUserName != curr.typingUserName,
      builder: (context, state) {
        if (state.typingUserName == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
              const SizedBox(width: 8),
              Text(
                state.typingUserName!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Message input ────────────────────────────────────────────────────────────

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String> onChanged;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file_outlined),
              tooltip: 'Dosya paylaş',
              onPressed: () => _showFileShareSheet(context),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz...',
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<MessageCubit, MessageState>(
              builder: (context, state) => FilledButton(
                onPressed: state.sending ? null : onSend,
                style: FilledButton.styleFrom(
                  backgroundColor: ConstColor.primary,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  minimumSize: Size.zero,
                ),
                child: state.sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFileShareSheet(BuildContext context) async {
    final cubit = context.read<MessageCubit>();
    final picked = await showModalBottomSheet<_PickedFile?>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FilePickerOptionsSheet(),
    );
    if (picked == null || !context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _FileConfirmSheet(file: picked),
      ),
    );
  }
}

// ─── File attachment card ─────────────────────────────────────────────────────

class _FileAttachmentCard extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Color textColor;

  const _FileAttachmentCard({
    required this.message,
    required this.isMe,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final attachment =
        message.attachments.isNotEmpty ? message.attachments.first : null;
    final fileName = attachment?.fileName ?? message.content;
    final isImage = message.messageType == 'IMAGE';

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (isImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: attachment?.fileUrl != null && attachment!.fileUrl!.isNotEmpty
                ? Image.network(
                    attachment.fileUrl!,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          )
        else
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isMe ? Colors.white : ConstColor.primary)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insert_drive_file_outlined,
                    size: 28,
                    color: isMe ? Colors.white : ConstColor.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (attachment != null)
                        Text(
                          attachment.formattedSize,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (attachment?.fileUrl != null && attachment!.fileUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(attachment.fileUrl!);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                isImage ? 'Tam ekran aç' : 'İndir',
                style: TextStyle(
                  color: isMe ? Colors.white : ConstColor.primary,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: isMe ? Colors.white : ConstColor.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _imagePlaceholder() => Container(
        width: 200,
        height: 140,
        color: Colors.grey.shade700,
        child: const Center(
          child: Icon(Icons.image_outlined, size: 48, color: Colors.white54),
        ),
      );
}

// ─── File share sheet ─────────────────────────────────────────────────────────

class _PickedFile {
  final String name;
  final int size; // bytes
  final String mimeType;
  final String? localPath;
  final bool isImage;

  const _PickedFile({
    required this.name,
    required this.size,
    required this.mimeType,
    this.localPath,
    required this.isImage,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    final kb = size / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}

class _FilePickerOptionsSheet extends StatelessWidget {
  const _FilePickerOptionsSheet();

  Future<void> _pickGallery(BuildContext ctx) async {
    final xFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xFile == null || !ctx.mounted) return;
    final size = await xFile.length();
    if (!ctx.mounted) return;
    final mime =
        xFile.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
    Navigator.of(ctx).pop(_PickedFile(
        name: xFile.name,
        size: size,
        mimeType: mime,
        localPath: xFile.path,
        isImage: true));
  }

  Future<void> _pickVideo(BuildContext ctx) async {
    final xFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (xFile == null || !ctx.mounted) return;
    final size = await xFile.length();
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop(_PickedFile(
        name: xFile.name,
        size: size,
        mimeType: 'video/mp4',
        localPath: xFile.path,
        isImage: false));
  }

  Future<void> _pickCamera(BuildContext ctx) async {
    final xFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 85);
    if (xFile == null || !ctx.mounted) return;
    final size = await xFile.length();
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop(_PickedFile(
        name: xFile.name,
        size: size,
        mimeType: 'image/jpeg',
        localPath: xFile.path,
        isImage: true));
  }

  Future<void> _pickDocument(BuildContext ctx) async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: false);
    if (result == null || result.files.isEmpty || !ctx.mounted) return;
    final f = result.files.first;
    Navigator.of(ctx).pop(_PickedFile(
        name: f.name,
        size: f.size,
        mimeType: _mimeFromExt(f.extension),
        localPath: f.path,
        isImage: false));
  }

  String _mimeFromExt(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'mp4':
      case 'mov':
      case 'avi':
        return 'video/mp4';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PickOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeri',
                  color: Colors.purple,
                  onTap: () => _pickGallery(context),
                ),
                _PickOption(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  color: Colors.red,
                  onTap: () => _pickVideo(context),
                ),
                _PickOption(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Belge',
                  color: Colors.blue,
                  onTap: () => _pickDocument(context),
                ),
                _PickOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Kamera',
                  color: Colors.green,
                  onTap: () => _pickCamera(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PickOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PickOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _FileConfirmSheet extends StatefulWidget {
  final _PickedFile file;
  const _FileConfirmSheet({required this.file});

  @override
  State<_FileConfirmSheet> createState() => _FileConfirmSheetState();
}

class _FileConfirmSheetState extends State<_FileConfirmSheet> {
  bool _sending = false;

  Future<void> _send() async {
    setState(() => _sending = true);
    await context.read<MessageCubit>().sendFileMessage(
          fileName: widget.file.name,
          fileSize: widget.file.size,
          mimeType: widget.file.mimeType,
          fileUrl: null,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.file.isImage && widget.file.localPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.file.localPath!),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _docTile(context),
              ),
            )
          else
            _docTile(context),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('İptal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _sending ? null : _send,
                  style: FilledButton.styleFrom(
                    backgroundColor: ConstColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Gönder'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _docTile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ConstColor.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.insert_drive_file_outlined,
                color: ConstColor.primary, size: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.file.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  widget.file.formattedSize,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Members drawer ───────────────────────────────────────────────────────────

class _MembersDrawer extends StatelessWidget {
  final ChannelModel channel;
  const _MembersDrawer({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kanal Üyeleri',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<ChannelMembersCubit, ChannelMembersState>(
                builder: (context, state) {
                  if (state.status == ChannelMembersStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == ChannelMembersStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage ?? 'Hata oluştu.'),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context
                                .read<ChannelMembersCubit>()
                                .fetchMembers(),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.members.length,
                    itemBuilder: (context, i) {
                      final member = state.members[i];
                      return _MemberTile(
                        member: member,
                        isRemoving: state.removingUserId == member.id,
                        onRemove: () => context
                            .read<ChannelMembersCubit>()
                            .removeMember(member.id),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () => _showAddMemberModal(context),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Kişi Ekle'),
                style: FilledButton.styleFrom(
                  backgroundColor: ConstColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<ChannelMembersCubit>()..fetchOrgUsers(),
        child: const _AddMemberSheet(),
      ),
    );
  }
}

// ─── Member tile ──────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  final ChannelMemberModel member;
  final bool isRemoving;
  final VoidCallback onRemove;

  const _MemberTile({
    required this.member,
    required this.isRemoving,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: ConstColor.primary.withValues(alpha: 0.15),
            child: Text(
              member.fullName.isNotEmpty
                  ? member.fullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: ConstColor.primary, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: member.presenceStatus == 'ONLINE'
                    ? Colors.green
                    : member.presenceStatus == 'BUSY'
                        ? Colors.amber
                        : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(member.fullName,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        member.isAdmin ? 'Kanal Yöneticisi' : 'Üye',
        style: TextStyle(
          color: member.isAdmin ? ConstColor.primary : null,
          fontSize: 12,
          fontWeight: member.isAdmin ? FontWeight.w600 : null,
        ),
      ),
      trailing: isRemoving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: Colors.red.shade400,
              tooltip: 'Çıkar',
              onPressed: onRemove,
            ),
    );
  }
}

// ─── Add member sheet ─────────────────────────────────────────────────────────

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet();

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Kişi Ekle',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            onChanged: (q) =>
                context.read<ChannelMembersCubit>().fetchOrgUsers(query: q),
          ),
          const SizedBox(height: 8),
          const Divider(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: BlocBuilder<ChannelMembersCubit, ChannelMembersState>(
              builder: (context, state) {
                if (state.orgUsersLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final users = state.filteredOrgUsers;
                if (users.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child:
                        Center(child: Text('Eklenecek kullanıcı bulunamadı.')),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final user = users[i];
                    final isAdding = state.addingUserId == user.id;
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                ConstColor.primary.withValues(alpha: 0.12),
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: ConstColor.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: user.isOnline
                                    ? Colors.green
                                    : Colors.grey.shade400,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(user.fullName),
                      trailing: isAdding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onTap: isAdding
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              context
                                  .read<ChannelMembersCubit>()
                                  .addMember(user.id);
                            },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
