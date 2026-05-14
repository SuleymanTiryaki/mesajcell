import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/utility/const/constant_color.dart';
import '../../auth/service/auth_service.dart';
import '../../auth/view/otp_verify_view.dart';
import '../cubit/invite_info_cubit.dart';
import '../cubit/register_cubit.dart';
import 'register_admin_view.dart';

/// Kayıt seçim ekranı — Şirketini Kur / Davetle Katıl
class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Nasıl devam etmek istersiniz?',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Yeni bir şirket kurabilir veya\nmevcut bir şirkete davet kodu ile katılabilirsiniz.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Şirketini Kur kartı
              _OptionCard(
                icon: Icons.business_center_outlined,
                title: 'Şirketini Kur',
                subtitle: 'Yeni bir şirket oluştur ve admin ol.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegisterAdminView(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Davetle Katıl kartı
              _OptionCard(
                icon: Icons.group_add_outlined,
                title: 'Davetle Katıl',
                subtitle: 'Davet koduyla mevcut şirkete katıl.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _InviteRegisterView(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: ConstColor.primary.withOpacity(0.12),
                child: Icon(icon, color: ConstColor.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Davetle Katıl formu ────────────────────────────────────────────────────

class _InviteRegisterView extends StatelessWidget {
  const _InviteRegisterView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => InviteInfoCubit()),
        BlocProvider(
          create: (_) => RegisterCubit(service: AuthService(AppDio.create())),
        ),
      ],
      child: const _InviteRegisterBody(),
    );
  }
}

class _InviteRegisterBody extends StatefulWidget {
  const _InviteRegisterBody();

  @override
  State<_InviteRegisterBody> createState() => _InviteRegisterBodyState();
}

class _InviteRegisterBodyState extends State<_InviteRegisterBody> {
  final _linkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RegisterCubit, RegisterState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (context, state) {
            if (state.status == RegisterStatus.success) {
              final gsm =
                  context.read<RegisterCubit>().gsmController.text.trim();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OtpVerifyView(gsmNumber: gsm),
                ),
              );
              return;
            }
            if (state.status == RegisterStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              context.read<RegisterCubit>().clearError();
            }
          },
        ),
        BlocListener<InviteInfoCubit, InviteInfoState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (context, state) {
            if (state.status == InviteInfoStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Davetle Katıl'),
          leading: const BackButton(),
        ),
        body: SafeArea(
          child: BlocBuilder<InviteInfoCubit, InviteInfoState>(
            builder: (context, inviteState) {
              if (inviteState.status == InviteInfoStatus.success) {
                return _buildRegisterForm(context, inviteState);
              }
              return _buildLinkStep(context, inviteState);
            },
          ),
        ),
      ),
    );
  }

  // ─── Adım 1: Davet linki yapıştırma ───────────────────────────────────────
  Widget _buildLinkStep(BuildContext context, InviteInfoState inviteState) {
    final isLoading = inviteState.status == InviteInfoStatus.loading;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.link_rounded, size: 56, color: ConstColor.primary),
          const SizedBox(height: 24),
          Text(
            'Davet Linki',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Size gönderilen davet linkini aşağıya yapıştırın.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _linkController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Davet Linki',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.insert_link_outlined),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isLoading
                ? null
                : () {
                    final link = _linkController.text.trim();
                    if (link.isEmpty) return;
                    context.read<InviteInfoCubit>().fetchFromLink(link);
                  },
            style: FilledButton.styleFrom(
              backgroundColor: ConstColor.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ConstColor.white,
                    ),
                  )
                : const Text(
                    'Devam Et',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Adım 2: Kayıt formu ──────────────────────────────────────────────────
  Widget _buildRegisterForm(BuildContext context, InviteInfoState inviteState) {
    final cubit = context.read<RegisterCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Org başlığı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ConstColor.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: ConstColor.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${inviteState.orgName}'e davet edildiniz!",
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ConstColor.primary,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Hesap Bilgileri',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Ad Soyad
            TextFormField(
              controller: cubit.fullNameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ad Soyad boş bırakılamaz.'
                  : null,
            ),
            const SizedBox(height: 16),

            // GSM Numarası
            TextFormField(
              controller: cubit.gsmController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'GSM Numarası',
                hintText: '+905559876543',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return 'Geçerli bir GSM numarası girin.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Şifre
            TextFormField(
              controller: cubit.passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 6) {
                  return 'Şifre en az 6 karakter olmalıdır.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Kayıt ol butonu
            BlocBuilder<RegisterCubit, RegisterState>(
              buildWhen: (p, c) => p.status != c.status,
              builder: (context, registerState) {
                final isLoading = registerState.status == RegisterStatus.loading;
                return FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<RegisterCubit>().register(
                                  inviteToken: inviteState.inviteToken!,
                                );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: ConstColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ConstColor.white,
                          ),
                        )
                      : const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Farklı link kullan
            Center(
              child: TextButton.icon(
                onPressed: () => context.read<InviteInfoCubit>().reset(),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Farklı bir link kullan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

