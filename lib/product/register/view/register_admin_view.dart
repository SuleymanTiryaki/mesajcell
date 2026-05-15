import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/utility/const/constant_color.dart';
import '../../auth/service/auth_service.dart';
import '../cubit/register_admin_cubit.dart';

class RegisterAdminView extends StatelessWidget {
  const RegisterAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterAdminCubit(
        service: AuthService(AppDio.create()),
      ),
      child: const _RegisterAdminBody(),
    );
  }
}

class _RegisterAdminBody extends StatefulWidget {
  const _RegisterAdminBody();

  @override
  State<_RegisterAdminBody> createState() => _RegisterAdminBodyState();
}

class _RegisterAdminBodyState extends State<_RegisterAdminBody> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterAdminCubit>();

    return BlocListener<RegisterAdminCubit, RegisterAdminState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == RegisterAdminStatus.success) {
          final gsm = context.read<RegisterAdminCubit>().gsmController.text.trim();
          context.go('/otp?gsm=${Uri.encodeComponent(gsm)}');
          return;
        }

        if (state.status == RegisterAdminStatus.error &&
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
          context.read<RegisterAdminCubit>().clearError();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Şirketini Kur'),
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
                    'Yeni Şirket Oluştur',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Şirketinizi kurun ve admin hesabınızı oluşturun.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Kişisel Bilgiler ───────────────────────────────────
                  _sectionHeader(context, 'Kişisel Bilgiler'),
                  const SizedBox(height: 12),

                  _buildField(
                    controller: cubit.gsmController,
                    label: 'GSM Numarası',
                    hint: '+905551234567',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Geçerli bir GSM numarası girin.'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: cubit.fullNameController,
                    label: 'Ad Soyad',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ad Soyad boş bırakılamaz.'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: cubit.emailController,
                    label: 'E-posta',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || !v.contains('@'))
                            ? 'Geçerli bir e-posta adresi girin.'
                            : null,
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
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Şifre en az 6 karakter olmalıdır.'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ─── Şirket Bilgileri ───────────────────────────────────
                  _sectionHeader(context, 'Şirket Bilgileri'),
                  const SizedBox(height: 12),

                  _buildField(
                    controller: cubit.orgNameController,
                    label: 'Şirket Adı',
                    icon: Icons.business_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Şirket adı boş bırakılamaz.'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: cubit.orgDomainController,
                    label: 'Şirket Domain',
                    hint: 'acme.com',
                    icon: Icons.language_outlined,
                    keyboardType: TextInputType.url,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Domain boş bırakılamaz.'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _buildField(
                    controller: cubit.orgLogoController,
                    label: 'Logo URL (opsiyonel)',
                    hint: 'https://example.com/logo.png',
                    icon: Icons.image_outlined,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 32),

                  // Kayıt butonu
                  BlocBuilder<RegisterAdminCubit, RegisterAdminState>(
                    buildWhen: (p, c) => p.status != c.status,
                    builder: (context, state) {
                      final isLoading =
                          state.status == RegisterAdminStatus.loading;
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
                                'Şirketi Kur',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: ConstColor.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ],
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
      context.read<RegisterAdminCubit>().registerAdmin();
    }
  }
}
