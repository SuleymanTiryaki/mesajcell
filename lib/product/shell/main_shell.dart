import 'package:flutter/material.dart';
import '../../features/core/socket_service.dart';
import '../channel/view/public_channels_view.dart';
import '../home/view/home_view.dart';
import '../settings/view/settings_view.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SocketService.instance.connect();
  }

  @override
  void dispose() {
    SocketService.instance.disconnect();
    super.dispose();
  }

  static const _pages = [
    HomeView(),
    PublicChannelsView(),
    _PlaceholderView('Güncellemeler'),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Sohbetler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Açık Kanallar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle_notifications_outlined),
            activeIcon: Icon(Icons.circle_notifications),
            label: 'Güncellemeler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Siz',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  final String label;
  const _PlaceholderView(this.label);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
