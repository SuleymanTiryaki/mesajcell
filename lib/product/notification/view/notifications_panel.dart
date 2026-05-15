import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/utility/const/constant_color.dart';
import '../cubit/notification_cubit.dart';
import '../model/notification_model.dart';

class NotificationsPanel {
  const NotificationsPanel._();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<NotificationCubit>()..fetchNotifications(),
        child: const _NotificationsPanelBody(),
      ),
    );
  }
}

class _NotificationsPanelBody extends StatefulWidget {
  const _NotificationsPanelBody();

  @override
  State<_NotificationsPanelBody> createState() =>
      _NotificationsPanelBodyState();
}

class _NotificationsPanelBodyState extends State<_NotificationsPanelBody> {
  @override
  void initState() {
    super.initState();
    // Açılır açılmaz tümünü okundu yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCubit>().markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          _handle(),
          _header(context),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state.status == NotifStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == NotifStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? 'Hata oluştu.'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              context.read<NotificationCubit>().fetchNotifications(),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }
                if (state.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bildirim yok',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollCtrl,
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (_, i) =>
                      _NotificationTile(notif: state.notifications[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _handle() => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.notifications_outlined),
            const SizedBox(width: 8),
            Text(
              'Bildirimler',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notif;
  const _NotificationTile({required this.notif});

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.isRead;
    return Container(
      color: isUnread
          ? ConstColor.primary.withValues(alpha: 0.06)
          : Colors.transparent,
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ConstColor.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(notif.icon, color: ConstColor.primary, size: 22),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notif.displayText,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          _formatTime(notif.createdAt),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
