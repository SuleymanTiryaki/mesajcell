import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/utility/const/constant_color.dart';
import '../../auth/service/auth_service.dart';
import '../../auth/view/otp_verify_view.dart';
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
    return BlocProvider(
      create: (_) => RegisterCubit(
        service: AuthService(AppDio.create()),
      ),
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
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          final gsm = context.read<RegisterCubit>().gsmController.text.trim();
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Davetle Katıl'),
          leading: const BackButton(),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Başlık
                  Text(
                    'Yeni Hesap Oluştur',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bilgilerinizi eksiksiz doldurun.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // GSM Numarası
                  _buildField(
                    controller: context.read<RegisterCubit>().gsmController,
                    label: 'GSM Numarası',
                    hint: '+905559876543',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().length < 10) {
                        return 'Geçerli bir GSM numarası girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ad Soyad
                  _buildField(
                    controller: context.read<RegisterCubit>().fullNameController,
                    label: 'Ad Soyad',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ad Soyad boş bırakılamaz.' : null,
                  ),
                  const SizedBox(height: 16),

                  // E-posta
                  _buildField(
                    controller: context.read<RegisterCubit>().emailController,
                    label: 'E-posta',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || !v.contains('@')) {
                        return 'Geçerli bir e-posta adresi girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Şifre
                  TextFormField(
                    controller: context.read<RegisterCubit>().passwordController,
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
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return 'Şifre en az 6 karakter olmalıdır.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Organizasyon ID
                  _buildField(
                    controller: context.read<RegisterCubit>().orgIdController,
                    label: 'Organizasyon ID',
                    icon: Icons.business_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Organizasyon ID boş bırakılamaz.' : null,
                  ),
                  const SizedBox(height: 32),

                  // Kayıt ol butonu
                  BlocBuilder<RegisterCubit, RegisterState>(
                    buildWhen: (p, c) => p.status != c.status,
                    builder: (context, state) {
                      final isLoading = state.status == RegisterStatus.loading;
                      return FilledButton(
                        onPressed:
                            isLoading ? null : () => _submit(context),
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

                  // Zaten hesabın var mı?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zaten hesabınız var mı?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Giriş Yap',
                          style: TextStyle(
                            color: ConstColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegisterCubit>().register();
    }
  }
}
