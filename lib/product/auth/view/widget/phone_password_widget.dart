import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/utility/const/constant_color.dart';
import '../../cubit/auth_cubit.dart';

/// Telefon numarası + şifre girilen 1. adım
class PhonePasswordWidget extends StatefulWidget {
  const PhonePasswordWidget({super.key});

  @override
  State<PhonePasswordWidget> createState() => _PhonePasswordWidgetState();
}

class _PhonePasswordWidgetState extends State<PhonePasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Telefon numarası
          TextFormField(
            controller: cubit.phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Telefon Numarası',
              prefixIcon: Icon(Icons.phone_outlined),
              prefixText: '+90 ',
            ),
            validator: (v) {
              if (v == null || v.trim().length < 10) {
                return 'Geçerli bir telefon numarası girin.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Şifre
          TextFormField(
            controller: cubit.passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
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
            onFieldSubmitted: (_) => _submit(cubit),
          ),
          const SizedBox(height: 28),

          // Giriş butonu
          BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, state) {
              final isLoading = state.status == AuthStatus.loading;
              return FilledButton(
                onPressed: isLoading ? null : () => _submit(cubit),
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
    );
  }

  void _submit(AuthCubit cubit) {
    if (_formKey.currentState?.validate() ?? false) {
      cubit.login();
    }
  }
}
