import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/utility/const/constant_color.dart';
import '../../auth/service/auth_service.dart';
import '../cubit/register_cubit.dart';

class RegisterView extends StatelessWidget {
  final String inviteToken;
  final String orgName;

  const RegisterView({
    super.key,
    required this.inviteToken,
    required this.orgName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(service: AuthService(AppDio.create())),
      child: _RegisterBody(inviteToken: inviteToken, orgName: orgName),
    );
  }
}

class _RegisterBody extends StatefulWidget {
  final String inviteToken;
  final String orgName;

  const _RegisterBody({required this.inviteToken, required this.orgName});

  @override
  State<_RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<_RegisterBody> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          final gsm = cubit.gsmController.text.trim();
          context.go('/otp?gsm=${Uri.encodeComponent(gsm)}');
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
          title: const Text('Kayıt Ol'),
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
                            "${widget.orgName}'e davet edildiniz!",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
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

                  TextFormField(
                    controller: cubit.gsmController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'GSM Numarası',
                      hintText: '+905559876543',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().length < 10)
                            ? 'Geçerli bir GSM numarası girin.'
                            : null,
                  ),
                  const SizedBox(height: 16),

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
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Şifre en az 6 karakter olmalıdır.'
                        : null,
                  ),
                  const SizedBox(height: 32),

                  BlocBuilder<RegisterCubit, RegisterState>(
                    buildWhen: (p, c) => p.status != c.status,
                    builder: (context, regState) {
                      final isLoading =
                          regState.status == RegisterStatus.loading;
                      return FilledButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  context.read<RegisterCubit>().register(
                                        inviteToken: widget.inviteToken,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
