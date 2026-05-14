import 'package:flutter/material.dart';
import 'package:mesajcell/features/core/socket_service.dart';
import 'package:mesajcell/product/channel/view/public_channels_view.dart';
import 'package:mesajcell/product/home/view/home_view.dart';
import 'package:mesajcell/product/settings/view/settings_view.dart';

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

  static const List<Widget> _pages = [
    HomeView(),
    PublicChannelsView(),
    _PlaceholderView(label: 'Güncelleme', icon: Icons.circle_notifications_outlined),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        indicatorColor: const Color(0xFF6C3EED).withAlpha(30),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Sohbetler',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Açık Kanallar',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_notifications_outlined),
            selectedIcon: Icon(Icons.circle_notifications),
            label: 'Güncellemeler',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Siz',
          ),
        ],
      ),
    );
  }
}

/// Henüz geliştirilmemiş sekmeler için geçici placeholder
class _PlaceholderView extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PlaceholderView({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
