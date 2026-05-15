import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/utility/const/constant_color.dart';
import '../cubit/auth_cubit.dart';
import '../service/auth_service.dart';
import 'widget/otp_widget.dart';
import 'widget/phone_password_widget.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(
        service: AuthService(AppDio.create()),
      ),
      child: const _AuthBody(),
    );
  }
}

class _AuthBody extends StatelessWidget {
  const _AuthBody();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == AuthStatus.loginSuccess ||
            state.status == AuthStatus.otpVerified) {
          context.go('/home');
          return;
        }

        // Hata göster
        if (state.status == AuthStatus.error &&
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
          context.read<AuthCubit>().clearError();
        }

        // OTP tekrar gönderildi
        if (state.status == AuthStatus.otpResent) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Doğrulama kodu tekrar gönderildi.'),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
              ),
            );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Logo / başlık
                Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: ConstColor.primary,
                      child: const Icon(
                        Icons.message_outlined,
                        color: ConstColor.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MesajCell',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (p, c) => p.step != c.step,
                      builder: (context, state) {
                        return Text(
                          state.step == AuthStep.phone
                              ? 'Telefon numaranız ve şifrenizle giriş yapın'
                              : 'Telefonunuza gelen kodu girin',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ],
                ),

                // const SizedBox(height: 40),
                // Adım göstergesi
                // BlocBuilder<AuthCubit, AuthState>(
                //   buildWhen: (p, c) => p.step != c.step,
                //   builder: (context, state) {
                //     return Row(
                //       children: [
                //         _StepDot(active: state.step == AuthStep.phone, label: '1'),
                //         Expanded(
                //           child: Divider(
                //             color: state.step == AuthStep.otp
                //                 ? ConstColor.primary
                //                 : Theme.of(context).colorScheme.outlineVariant,
                //             thickness: 2,
                //           ),
                //         ),
                //         _StepDot(active: state.step == AuthStep.otp, label: '2'),
                //       ],
                //     );
                //   },
                // ),

                const SizedBox(height: 32),

                // Adıma göre widget
                BlocBuilder<AuthCubit, AuthState>(
                  buildWhen: (p, c) => p.step != c.step,
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: state.step == AuthStep.phone
                          ? const PhonePasswordWidget(key: ValueKey('phone'))
                          : const OtpWidget(key: ValueKey('otp')),
                    );
                  },
                ),

                // Kaydınız yok mu?
                BlocBuilder<AuthCubit, AuthState>(
                  buildWhen: (p, c) => p.step != c.step,
                  builder: (context, state) {
                    if (state.step != AuthStep.phone) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kaydınız yok mu?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                color: ConstColor.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class _StepDot extends StatelessWidget {
//   final bool active;
//   final String label;

//   const _StepDot({required this.active, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 250),
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: active ? ConstColor.primary : Colors.transparent,
//         border: Border.all(
//           color: active
//               ? ConstColor.primary
//               : Theme.of(context).colorScheme.outlineVariant,
//           width: 2,
//         ),
//       ),
//       child: Center(
//         child: Text(
//           label,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: active
//                 ? ConstColor.white
//                 : Theme.of(context).colorScheme.onSurfaceVariant,
//           ),
//         ),
//       ),
//     );
//   }
// }

