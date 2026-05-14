import 'package:flutter/material.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import 'package:mesajcell/features/utility/const/constant_string.dart';
import '../../channel/view/create_channel_view.dart';
import '../model/chat_user_model.dart';
import 'widget/chat_tile.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatUser> _filteredUsers = mockUsers;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = mockUsers;
      } else {
        _filteredUsers = mockUsers
            .where(
              (user) =>
                  user.name.toLowerCase().contains(query.toLowerCase()) ||
                  user.lastMessage.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(ConstantString.chats),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const CreateChannelView(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: ConstantString.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Kullanıcı listesi
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Text(
                      ConstantString.noResultFound,
                      style: TextStyle(color: ConstColor.grey500),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (_, __) => const Divider(
                      indent: 80,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return ChatTile(user: user);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: ConstColor.primary,
        child: const Icon(Icons.message_outlined, color: ConstColor.white),
      ),
    );
  }
}
