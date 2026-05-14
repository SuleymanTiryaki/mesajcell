import 'package:flutter/material.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import '../../model/chat_user_model.dart';

class ChatTile extends StatelessWidget {
  final ChatUser user;

  const ChatTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: user.avatarColor,
        child: Text(
          user.avatarInitials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(user.name),
      subtitle: Text(
        user.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            user.time,
            style: TextStyle(
              color: user.unreadCount > 0
                  ? ConstColor.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          if (user.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ConstColor.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                user.unreadCount.toString(),
                style: const TextStyle(
                  color: ConstColor.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        // TODO: Sohbet detay sayfasına git
      },
    );
  }
}
