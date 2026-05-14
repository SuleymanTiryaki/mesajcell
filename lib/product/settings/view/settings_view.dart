import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import 'package:mesajcell/features/utility/notifier/theme_notifier.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Siz'),
      ),
      body: ListView(
        children: [
          // Profil kartı
          _ProfileCard(textTheme: textTheme, colorScheme: colorScheme),

          const SizedBox(height: 8),

          // Görünüm bölümü
          _SectionHeader(title: 'Görünüm'),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Karanlık Mod',
            trailing: Switch.adaptive(
              value: themeNotifier.isDark,
              activeColor: ConstColor.primary,
              onChanged: themeNotifier.toggleDark,
            ),
          ),
          _SettingsTile(
            icon: Icons.brightness_auto_outlined,
            title: 'Sisteme Göre Otomatik',
            trailing: Switch.adaptive(
              value: themeNotifier.themeMode == ThemeMode.system,
              activeColor: ConstColor.primary,
              onChanged: (val) {
                themeNotifier.setTheme(
                  val ? ThemeMode.system : ThemeMode.light,
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Bildirimler bölümü
          _SectionHeader(title: 'Bildirimler'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Bildirimler',
            onTap: () {
              // TODO: Bildirim ayarları
            },
          ),
          _SettingsTile(
            icon: Icons.volume_up_outlined,
            title: 'Sesler',
            onTap: () {
              // TODO: Ses ayarları
            },
          ),

          const SizedBox(height: 8),

          // Hesap bölümü
          _SectionHeader(title: 'Hesap'),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Gizlilik',
            onTap: () {
              // TODO: Gizlilik ayarları
            },
          ),
          _SettingsTile(
            icon: Icons.security_outlined,
            title: 'Güvenlik',
            onTap: () {
              // TODO: Güvenlik ayarları
            },
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Dil',
            subtitle: 'Türkçe',
            onTap: () {
              // TODO: Dil seçimi
            },
          ),

          const SizedBox(height: 8),

          // Hakkında
          _SectionHeader(title: 'Hakkında'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Uygulama Hakkında',
            subtitle: 'Sürüm 1.0.0',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Çıkış butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Çıkış yap
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.textTheme, required this.colorScheme});

  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: ConstColor.primary,
            child: const Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kullanıcı Adı',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Durum mesajı ekle...',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Profil düzenleme
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ConstColor.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: ConstColor.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, size: 20)
              : null),
      onTap: onTap,
    );
  }
}
