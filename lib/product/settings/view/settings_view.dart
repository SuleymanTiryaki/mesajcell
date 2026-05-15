import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import 'package:mesajcell/features/utility/notifier/theme_notifier.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/service/auth_service.dart';
import '../../../features/core/app_dio.dart';
import '../cubit/settings_cubit.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(service: AuthService(AppDio.create()))),
        BlocProvider(create: (_) => SettingsCubit()..loadMe()),
      ],
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
          context.go('/welcome');
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

// ─── Profile card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.textTheme, required this.colorScheme});

  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final me = state.me;
        final fullName = me?.fullName ?? '—';
        final email = me?.email ?? '';
        final initials = fullName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();
        final photoUrl = me?.profilePhotoUrl;
        final isLoading = state.status == SettingsStatus.loading;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: ConstColor.primary,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? Text(
                        isLoading ? '…' : initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isLoading
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Shimmer(width: 120, height: 14),
                          SizedBox(height: 6),
                          _Shimmer(width: 160, height: 11),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          _PresenceBadge(status: me?.presenceStatus ?? 'OFFLINE'),
                        ],
                      ),
              ),
              // Düzenle butonu
              IconButton(
                onPressed: state.status == SettingsStatus.loading
                    ? null
                    : () => _showEditSheet(context),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: const _EditProfileSheet(),
      ),
    );
  }
}

// ─── Presence badge ───────────────────────────────────────────────────────────

class _PresenceBadge extends StatelessWidget {
  final String status;
  const _PresenceBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status.toUpperCase()) {
      'ONLINE' => (Colors.green, 'Çevrimiçi'),
      'AWAY' => (Colors.orange, 'Uzakta'),
      'BUSY' => (Colors.red, 'Meşgul'),
      _ => (Colors.grey, 'Çevrimdışı'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4, top: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}

// ─── Shimmer placeholder ──────────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;
  const _Shimmer({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Edit profile sheet ───────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _photoCtrl;
  String _presenceStatus = 'ONLINE';

  @override
  void initState() {
    super.initState();
    final me = context.read<SettingsCubit>().state.me;
    _nameCtrl = TextEditingController(text: me?.fullName ?? '');
    _emailCtrl = TextEditingController(text: me?.email ?? '');
    _photoCtrl = TextEditingController(text: me?.profilePhotoUrl ?? '');
    _presenceStatus = me?.presenceStatus.toUpperCase() ?? 'ONLINE';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Profili Düzenle',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Ad Soyad
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ad Soyad boş olamaz' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // E-posta
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'E-posta boş olamaz';
                if (!v.contains('@')) return 'Geçerli bir e-posta girin';
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // Profil fotoğrafı URL
            TextFormField(
              controller: _photoCtrl,
              decoration: const InputDecoration(
                labelText: 'Profil Fotoğrafı URL (isteğe bağlı)',
                prefixIcon: Icon(Icons.image_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // Durum seçici
            DropdownButtonFormField<String>(
              value: _presenceStatus,
              decoration: const InputDecoration(
                labelText: 'Durum',
                prefixIcon: Icon(Icons.circle, color: Colors.green, size: 16),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'ONLINE', child: Text('Çevrimiçi')),
                DropdownMenuItem(value: 'AWAY', child: Text('Uzakta')),
                DropdownMenuItem(value: 'BUSY', child: Text('Meşgul')),
                DropdownMenuItem(value: 'OFFLINE', child: Text('Çevrimdışı')),
              ],
              onChanged: (v) => setState(() => _presenceStatus = v ?? 'ONLINE'),
            ),
            const SizedBox(height: 24),

            // Kaydet butonu
            BlocConsumer<SettingsCubit, SettingsState>(
              listenWhen: (p, c) => p.saving && !c.saving,
              listener: (context, state) {
                if (state.errorMessage == null) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil güncellendi')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                return FilledButton(
                  onPressed: state.saving ? null : _save,
                  child: state.saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Kaydet'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SettingsCubit>().updateMe(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          profilePhotoUrl: _photoCtrl.text.trim(),
          presenceStatus: _presenceStatus,
        );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

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
