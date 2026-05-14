import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/socket_service.dart';
import '../../../features/utility/const/constant_color.dart';
import '../cubit/channel_members_cubit.dart';
import '../cubit/message_cubit.dart';
import '../model/channel_member_model.dart';
import '../model/channel_message_model.dart';
import '../model/channel_model.dart';

class ChannelView extends StatelessWidget {
  final ChannelModel channel;

  const ChannelView({super.key, required this.channel});

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
      child: _ChannelViewBody(channel: channel),
    );
  }
}

// ─── Body (stateful — TextController + ScrollController burada yaşar) ─────────

class _ChannelViewBody extends StatefulWidget {
  final ChannelModel channel;
  const _ChannelViewBody({required this.channel});

  @override
  State<_ChannelViewBody> createState() => _ChannelViewBodyState();
}

class _ChannelViewBodyState extends State<_ChannelViewBody> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    // Typing bitti
    SocketService.instance.sendTyping(widget.channel.id, isTyping: false);
    context.read<MessageCubit>().sendMessage(text);
  }

  void _onTextChanged(String value) {
    SocketService.instance.sendTyping(
      widget.channel.id,
      isTyping: value.isNotEmpty,
    );
  }

  void _sendReadReceipt(List<MessageModel> messages) {
    if (messages.isEmpty) return;
    SocketService.instance
        .sendReadReceipt(widget.channel.id, messages.last.id);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Yeni mesaj gelince en alta kaydır + read receipt gönder
        BlocListener<MessageCubit, MessageState>(
          listenWhen: (prev, curr) =>
              curr.messages.length != prev.messages.length,
          listener: (ctx, st) {
            _scrollToBottom();
            _sendReadReceipt(st.messages);
          },
        ),
        // Mesajlar ilk yüklenince read receipt gönder
        BlocListener<MessageCubit, MessageState>(
          listenWhen: (prev, curr) =>
              prev.status != MessageStatus.success &&
              curr.status == MessageStatus.success,
          listener: (ctx, st) => _sendReadReceipt(st.messages),
        ),
        // Üye işlemi SnackBar
        BlocListener<ChannelMembersCubit, ChannelMembersState>(
          listenWhen: (prev, curr) =>
              curr.lastActionMessage != null &&
              curr.lastActionMessage != prev.lastActionMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.lastActionMessage!)),
            );
            context.read<ChannelMembersCubit>().clearActionMessage();
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('# ${widget.channel.name}'),
          titleSpacing: 0,
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
        body: Column(
          children: [
            Expanded(child: _ChatArea(scrollController: _scrollController)),
            _TypingIndicator(),
          ],
        ),
        bottomNavigationBar: _MessageInput(
          controller: _textController,
          onSend: _send,
          onChanged: _onTextChanged,
          onEditingComplete: () =>
              SocketService.instance.sendTyping(widget.channel.id, isTyping: false),
        ),
      ),
    );
  }
}

// ─── Mesaj listesi ────────────────────────────────────────────────────────────

class _ChatArea extends StatelessWidget {
  final ScrollController scrollController;
  const _ChatArea({required this.scrollController});

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
                  onPressed: () =>
                      context.read<MessageCubit>().fetchMessages(),
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
                Icon(Icons.chat_bubble_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'Henüz mesaj yok',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İlk mesajı göndererek sohbeti başlat!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: state.messages.length,
          itemBuilder: (context, i) {
            final msg = state.messages[i];
            final prevMsg = i > 0 ? state.messages[i - 1] : null;
            final showSender =
                !msg.isMe && msg.senderId != prevMsg?.senderId;
            return _MessageBubble(message: msg, showSender: showSender);
          },
        );
      },
    );
  }
}

// ─── Mesaj balonu ─────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool showSender;

  const _MessageBubble({required this.message, required this.showSender});

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
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

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64 : 12,
        right: isMe ? 12 : 64,
        bottom: 4,
        top: showSender ? 8 : 2,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (showSender)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.senderName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ConstColor.primary,
                    ),
                  ),
                ),
              Text(message.content, style: TextStyle(color: textColor)),
              const SizedBox(height: 2),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(fontSize: 10, color: timeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Typing indicator ────────────────────────────────────────────────────────

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

// ─── Mesaj input bar ──────────────────────────────────────────────────────────

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onChanged,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                onChanged: onChanged,
                onEditingComplete: onEditingComplete,
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz...',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
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
}

// ─── Üyeler Drawer (sağdan açılır) ───────────────────────────────────────────

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

// ─── Üye satırı ───────────────────────────────────────────────────────────────

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
                color: Colors.green,
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
      title: Text(
        member.fullName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        member.isAdmin ? 'CHANNEL_ADMIN' : 'MEMBER',
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

// ─── Üye ekleme sheet ─────────────────────────────────────────────────────────

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
                child: Text(
                  'Kişi Ekle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
              fillColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    child: Center(
                        child: Text('Eklenecek kullanıcı bulunamadı.')),
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
                                  color: Theme.of(context).colorScheme.surface,
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
