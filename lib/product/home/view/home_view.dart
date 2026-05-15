import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import 'package:mesajcell/features/utility/const/constant_string.dart';
import '../../channel/cubit/channel_list_cubit.dart';
import '../../channel/view/create_channel_view.dart';
import '../../notification/cubit/notification_cubit.dart';
import '../../notification/view/notifications_panel.dart';
import 'widget/chat_tile.dart';
import 'widget/invite_sheet.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChannelListCubit()..fetchChannels()),
        BlocProvider(create: (_) => NotificationCubit()),
      ],
      child: const _HomeViewBody(),
    );
  }
}

class _HomeViewBody extends StatefulWidget {
  const _HomeViewBody();

  @override
  State<_HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<_HomeViewBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listenWhen: (prev, curr) =>
          curr.pendingMention != null &&
          curr.pendingMention != prev.pendingMention,
      listener: (ctx, state) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('${state.pendingMention} seni etiketledi'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Göster',
              onPressed: () => NotificationsPanel.show(ctx),
            ),
          ),
        );
        ctx.read<NotificationCubit>().clearPendingMention();
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: Text(ConstantString.chats),
          actions: [
            // 🔔 Bildirim ikonu
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (ctx, state) => IconButton(
                tooltip: 'Bildirimler',
                onPressed: () => NotificationsPanel.show(ctx),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    if (state.unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: state.unreadCount > 9
                              ? null
                              : null, // sadece nokta
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Davet Et',
              onPressed: () => showInviteSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const CreateChannelView(),
                  ),
                );
                if (context.mounted) {
                  context.read<ChannelListCubit>().fetchChannels();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: ConstantString.search,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: ConstColor.searchFieldBackground,
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              ),
            ),
            Expanded(
              child: BlocBuilder<ChannelListCubit, ChannelListState>(
                builder: (context, state) {
                  if (state.status == ChannelListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == ChannelListStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage ?? 'Bir hata oluştu.'),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                context.read<ChannelListCubit>().fetchChannels(),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    );
                  }
                  final channels = _query.isEmpty
                      ? state.channels
                      : state.channels
                          .where((c) =>
                              c.name.toLowerCase().contains(_query) ||
                              c.description.toLowerCase().contains(_query))
                          .toList();

                  if (channels.isEmpty) {
                    return Center(
                      child: Text(
                        state.channels.isEmpty
                            ? 'Henüz kanal yok.'
                            : ConstantString.noResultFound,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: channels.length,
                    itemBuilder: (context, i) => ChatTile(
                      channel: channels[i],
                      unreadCount: state.unreadFor(channels[i].id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

