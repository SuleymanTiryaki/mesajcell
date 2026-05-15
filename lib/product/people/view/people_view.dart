import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/utility/const/constant_color.dart';
import '../../channel/model/channel_member_model.dart';
import '../../channel/view/channel_view.dart';
import '../cubit/people_cubit.dart';

class PeopleView extends StatelessWidget {
  const PeopleView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PeopleCubit()..fetchUsers(),
      child: const _PeopleViewBody(),
    );
  }
}

class _PeopleViewBody extends StatefulWidget {
  const _PeopleViewBody();

  @override
  State<_PeopleViewBody> createState() => _PeopleViewBodyState();
}

class _PeopleViewBodyState extends State<_PeopleViewBody> {
  final _searchController = TextEditingController();

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
        title: const Text('Kişiler'),
        actions: [
          BlocBuilder<PeopleCubit, PeopleState>(
            buildWhen: (p, c) => p.creatingDm != c.creatingDm,
            builder: (_, state) => state.creatingDm
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PeopleCubit>().fetchUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama kutusu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Kişi ara...',
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
              onChanged: (v) => context.read<PeopleCubit>().filterUsers(v),
            ),
          ),
          Expanded(
            child: BlocBuilder<PeopleCubit, PeopleState>(
              builder: (context, state) {
                if (state.status == PeopleStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == PeopleStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? 'Hata oluştu.'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              context.read<PeopleCubit>().fetchUsers(),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }
                if (state.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.query.isEmpty
                              ? 'Organizasyonda başka üye yok'
                              : '"${state.query}" bulunamadı',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
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
                  itemCount: state.users.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, i) => _PersonTile(
                    user: state.users[i],
                    onTap: () => _startDm(context, state.users[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startDm(BuildContext context, OrgUserModel user) async {
    final cubit = context.read<PeopleCubit>();
    final channel = await cubit.createDm(user.id);
    if (!context.mounted) return;
    if (channel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sohbet başlatılamadı.')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChannelView(channel: channel)),
    );
  }
}

// ─── Person tile ──────────────────────────────────────────────────────────────

class _PersonTile extends StatelessWidget {
  final OrgUserModel user;
  final VoidCallback onTap;

  const _PersonTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOnline = user.presenceStatus == 'ONLINE';
    final initials = user.fullName.isNotEmpty
        ? user.fullName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join()
        : '?';

    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: ConstColor.primary.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: const TextStyle(
                color: ConstColor.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        user.fullName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
        style: TextStyle(
          color: isOnline ? Colors.green : Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chat_bubble_outline, size: 20),
    );
  }
}
