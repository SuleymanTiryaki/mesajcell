import 'package:flutter/material.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import '../../../channel/model/channel_model.dart';
import '../../../channel/view/channel_view.dart';

class ChatTile extends StatelessWidget {
  final ChannelModel channel;

  const ChatTile({super.key, required this.channel});

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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: ConstColor.primary.withOpacity(0.15),
        child: Icon(typeIcon, color: ConstColor.primary),
      ),
      title: Text(channel.name),
      subtitle: Text(
        channel.description.isNotEmpty ? channel.description : '—',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChannelView(channel: channel),
          ),
        );
      },
    );
  }
}


