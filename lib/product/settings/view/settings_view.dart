import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import 'package:mesajcell/features/utility/notifier/theme_notifier.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/service/auth_service.dart';
import '../../auth/view/auth_view.dart';
import '../../../features/core/app_dio.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(service: AuthService(AppDio.create())),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.loggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthView()),
            (_) => false,
          );
        }
      },
      child: Scaffold(
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
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.volume_up_outlined,
              title: 'Sesler',
              onTap: () {},
            ),

            const SizedBox(height: 8),

            // Hesap bölümü
            _SectionHeader(title: 'Hesap'),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Gizlilik',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.security_outlined,
              title: 'Güvenlik',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.language_outlined,
              title: 'Dil',
              subtitle: 'Türkçe',
              onTap: () {},
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
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state.status == AuthStatus.loading;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Çıkış Yap'),
                                content: const Text(
                                    'Hesabından çıkmak istediğine emin misin?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Çıkış Yap',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && context.mounted) {
                              context.read<AuthCubit>().logout();
                            }
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
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
