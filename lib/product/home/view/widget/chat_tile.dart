import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import '../../../channel/cubit/channel_list_cubit.dart';
import '../../../channel/model/channel_model.dart';
import '../../../channel/view/channel_view.dart';

class ChatTile extends StatelessWidget {
  final ChannelModel channel;
  final int unreadCount;

  const ChatTile({super.key, required this.channel, this.unreadCount = 0});

  @override
  Widget build(BuildContext context) {
    final IconData typeIcon;
    switch (channel.type) {
      case ChannelType.private:
        typeIcon = Icons.lock_outline;
        break;
      case ChannelType.dm:
        typeIcon = Icons.person_outline;
        break;
      case ChannelType.public:
        typeIcon = Icons.tag;
        break;
    }

    final isMuted = channel.isMuted;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: isMuted
            ? Colors.grey.withValues(alpha: 0.15)
            : ConstColor.primary.withValues(alpha: 0.15),
        child: Icon(
          typeIcon,
          color: isMuted ? Colors.grey : ConstColor.primary,
        ),
      ),
      title: Row(
        children: [
          if (isMuted)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.volume_off_outlined,
                  size: 14, color: Colors.grey.shade500),
            ),
          Expanded(
            child: Text(
              channel.name,
              style: TextStyle(
                color: isMuted
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
          ),
          if (unreadCount > 0)
            Container(
              constraints: const BoxConstraints(minWidth: 20),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      subtitle: Text(
        channel.description.isNotEmpty ? channel.description : '—',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: isMuted ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      onTap: () {
        // Kanala girilince unread sıfırla
        context.read<ChannelListCubit>().setActiveChannel(channel.id);
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (_) => ChannelView(channel: channel),
        ))
            .then((_) {
          if (context.mounted) {
            context.read<ChannelListCubit>().clearActiveChannel();
          }
        });
      },
      onLongPress: () => _showNotificationPrefSheet(context),
    );
  }

  void _showNotificationPrefSheet(BuildContext context) {
    final cubit = context.read<ChannelListCubit>();
    final current = channel.notificationPreference;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: ConstColor.primary),
                    const SizedBox(width: 8),
                    Text(
                      '# ${channel.name} Bildirimleri',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              _NotifPrefTile(
                icon: Icons.notifications_active_outlined,
                label: 'Tüm mesajlar',
                subtitle: 'Her yeni mesajda bildirim al',
                value: 'ALL',
                current: current,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  cubit.updateNotificationPreference(channel.id, 'ALL');
                },
              ),
              _NotifPrefTile(
                icon: Icons.alternate_email,
                label: 'Sadece Mentionlar',
                subtitle: '@etiketlenince bildirim al',
                value: 'MENTIONS_ONLY',
                current: current,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  cubit.updateNotificationPreference(
                      channel.id, 'MENTIONS_ONLY');
                },
              ),
              _NotifPrefTile(
                icon: Icons.notifications_off_outlined,
                label: 'Sessiz',
                subtitle: 'Hiç bildirim alma',
                value: 'MUTED',
                current: current,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  cubit.updateNotificationPreference(channel.id, 'MUTED');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifPrefTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String value;
  final String current;
  final VoidCallback onTap;

  const _NotifPrefTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? ConstColor.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? ConstColor.primary : null,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: ConstColor.primary)
          : null,
      onTap: onTap,
    );
  }
}


