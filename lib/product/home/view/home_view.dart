import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import 'package:mesajcell/features/utility/const/constant_string.dart';
import '../../channel/cubit/channel_list_cubit.dart';
import '../../channel/view/create_channel_view.dart';
import 'widget/chat_tile.dart';
import 'widget/invite_sheet.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChannelListCubit()..fetchChannels(),
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
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(ConstantString.chats),
        actions: [
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
              // Kanal oluşturulduktan sonra listeyi yenile
              if (context.mounted) {
                context.read<ChannelListCubit>().fetchChannels();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ChannelListCubit, ChannelListState>(
        builder: (context, state) {
          if (state.status == ChannelListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ChannelListStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage ?? 'Hata oluştu',
                    style: TextStyle(color: ConstColor.grey500),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        context.read<ChannelListCubit>().fetchChannels(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final channels = state.channels.where((c) {
            if (_query.isEmpty) return true;
            return c.name.toLowerCase().contains(_query.toLowerCase()) ||
                c.description.toLowerCase().contains(_query.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: ConstantString.search,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: channels.isEmpty
                    ? Center(
                        child: Text(
                          ConstantString.noResultFound,
                          style: TextStyle(color: ConstColor.grey500),
                        ),
                      )
                    : ListView.separated(
                        itemCount: channels.length,
                        separatorBuilder: (_, __) => const Divider(
                          indent: 80,
                          height: 1,
                        ),
                        itemBuilder: (context, index) =>
                            ChatTile(channel: channels[index]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: ConstColor.primary,
        child: const Icon(Icons.message_outlined, color: ConstColor.white),
      ),
    );
  }
}

