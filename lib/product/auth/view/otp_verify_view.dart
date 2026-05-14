import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/app_session.dart';
import '../../../features/utility/const/constant_color.dart';
import '../model/otp_model.dart';
import '../service/auth_service.dart';
import '../../shell/main_shell.dart';

/// Kayıt sonrası OTP doğrulama ekranı.
/// Kullanıcı kodu elle girer; yanlışsa hata gösterir.
class OtpVerifyView extends StatefulWidget {
  final String gsmNumber;

  const OtpVerifyView({super.key, required this.gsmNumber});

  @override
  State<OtpVerifyView> createState() => _OtpVerifyViewState();
}

class _OtpVerifyViewState extends State<OtpVerifyView> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  late final AuthService _service = AuthService(AppDio.create());

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _service.postVerifyOtp(
        OtpRequest(
          gsmNumber: widget.gsmNumber,
          otpCode: _otpController.text.trim(),
        ),
      );

      if (!mounted) return;

      if (response?.success == true) {
        AppLogger.i('[OtpVerifyView] OTP doğrulandı → MainShell');
        // Token'ları oturuma kaydet
        if (response!.accessToken != null) {
          AppSession.instance.setTokens(
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken,
          );
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (_) => false,
        );
      } else {
        final msg = response?.message ?? 'Doğrulama kodu hatalı.';
        AppLogger.w('[OtpVerifyView] OTP hata: $msg');
        _showError(msg);
        _otpController.clear();
      }
    } catch (e, st) {
      AppLogger.e('[OtpVerifyView] hata', error: e, stackTrace: st);
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doğrulama Kodu'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Telefon Doğrulama',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.gsmNumber} numarasına gönderilen kodu girin.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 40),

                // OTP input
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 28, letterSpacing: 12),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '• • • • • •',
                    hintStyle: TextStyle(letterSpacing: 12, fontSize: 28),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 4) {
                      return 'Lütfen doğrulama kodunu eksiksiz girin.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _isLoading ? null : _submit(),
                ),
                const SizedBox(height: 32),

                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: ConstColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
