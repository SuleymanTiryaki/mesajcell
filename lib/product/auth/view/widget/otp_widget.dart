import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/utility/const/constant_color.dart';
import '../../cubit/auth_cubit.dart';

/// OTP kodu girilen 2. adım
class OtpWidget extends StatefulWidget {
  const OtpWidget({super.key});

  @override
  State<OtpWidget> createState() => _OtpWidgetState();
}

class _OtpWidgetState extends State<OtpWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final phone = context.select((AuthCubit c) => c.state.phoneNumber) ?? '';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bilgi metni
          Text(
            '$phone numarasına gönderilen kodu girin.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 28),

          // OTP input
          TextFormField(
            controller: cubit.otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 28, letterSpacing: 12),
            decoration: const InputDecoration(
              counterText: '',
              hintText: '• • • • • •',
              hintStyle: TextStyle(letterSpacing: 12, fontSize: 28),
            ),
            validator: (v) {
              if (v == null || v.length < 4) {
                return 'Lütfen doğrulama kodunu eksiksiz girin.';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Doğrula butonu
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
                        'Doğrula',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Kodu tekrar gönder
          BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, state) {
              return TextButton(
                onPressed: state.status == AuthStatus.loading
                    ? null
                    : cubit.resendOtp,
                child: Text(
                  'Kodu tekrar gönder',
                  style: TextStyle(color: ConstColor.primary),
                ),
              );
            },
          ),

          // Geri butonu
          TextButton.icon(
            onPressed: cubit.backToPhone,
            icon: const Icon(Icons.arrow_back_ios_new, size: 14),
            label: const Text('Telefon numarasını değiştir'),
          ),
        ],
      ),
    );
  }

  void _submit(AuthCubit cubit) {
    if (_formKey.currentState?.validate() ?? false) {
      cubit.verifyOtp();
    }
  }
}
