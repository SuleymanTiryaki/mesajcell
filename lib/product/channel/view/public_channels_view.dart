import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import '../cubit/public_channel_list_cubit.dart';
import '../model/channel_model.dart';

class PublicChannelsView extends StatelessWidget {
  const PublicChannelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublicChannelListCubit()..fetchPublicChannels(),
      child: const _PublicChannelsBody(),
    );
  }
}

class _PublicChannelsBody extends StatefulWidget {
  const _PublicChannelsBody();

  @override
  State<_PublicChannelsBody> createState() => _PublicChannelsBodyState();
}

class _PublicChannelsBodyState extends State<_PublicChannelsBody> {
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
        title: const Text('Açık Kanallar'),
      ),
      body: BlocBuilder<PublicChannelListCubit, PublicChannelListState>(
        builder: (context, state) {
          if (state.status == PublicChannelListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PublicChannelListStatus.error) {
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
                    onPressed: () => context
                        .read<PublicChannelListCubit>()
                        .fetchPublicChannels(),
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
                    hintText: 'Kanal ara...',
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
                          'Açık kanal bulunamadı',
                          style: TextStyle(color: ConstColor.grey500),
                        ),
                      )
                    : ListView.separated(
                        itemCount: channels.length,
                        separatorBuilder: (_, __) => const Divider(
                          indent: 72,
                          height: 1,
                        ),
                        itemBuilder: (context, index) =>
                            _PublicChannelTile(channel: channels[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PublicChannelTile extends StatelessWidget {
  final ChannelModel channel;
  const _PublicChannelTile({required this.channel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: ConstColor.primary.withOpacity(0.15),
        child: const Icon(Icons.tag, color: ConstColor.primary),
      ),
      title: Text(
        channel.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: channel.description.isNotEmpty
          ? Text(
              channel.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: channel.memberCount > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${channel.memberCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          : null,
      onTap: () {
        // TODO: Kanala katıl / kanal detayı
      },
    );
  }
}
