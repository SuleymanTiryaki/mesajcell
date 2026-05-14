import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';
import '../../cubit/invite_cubit.dart';

/// Kalem ikonunun yanındaki paylaş ikonuna basılınca açılan sheet.
/// Email + GSM alanı alır, POST /api/v1/org/invite çağırır.
Future<void> showInviteSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => InviteCubit(),
      child: const _InviteSheetContent(),
    ),
  );
}

class _InviteSheetContent extends StatefulWidget {
  const _InviteSheetContent();

  @override
  State<_InviteSheetContent> createState() => _InviteSheetContentState();
}

class _InviteSheetContentState extends State<_InviteSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _gsmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _gsmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<InviteCubit>().sendInvite(
          email: _emailController.text.trim(),
          gsmNumber: _gsmController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InviteCubit, InviteState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == InviteStatus.error && state.errorMessage != null) {
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
          context.read<InviteCubit>().reset();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: BlocBuilder<InviteCubit, InviteState>(
          builder: (context, state) {
            // ── Başarı ekranı: link göster ──────────────────────────────────
            if (state.status == InviteStatus.success &&
                state.inviteData != null) {
              return _InviteLinkResult(link: state.inviteData!.inviteLink);
            }

            // ── Form ekranı ─────────────────────────────────────────────────
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Başlık çubuğu
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Kişi Davet Et',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'E-posta ve telefon numarasını girerek davetiye gönder.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // E-posta
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'E-posta boş bırakılamaz.';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(v.trim())) {
                        return 'Geçerli bir e-posta girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // GSM numarası
                  TextFormField(
                    controller: _gsmController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Telefon Numarası',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: '+905xxxxxxxxx',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Telefon numarası boş bırakılamaz.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Gönder butonu
                  FilledButton(
                    onPressed:
                        state.status == InviteStatus.loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: ConstColor.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.status == InviteStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Davet Gönder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Davet linki sonuç widget'ı ────────────────────────────────────────────────

class _InviteLinkResult extends StatelessWidget {
  final String link;
  const _InviteLinkResult({required this.link});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Başarı ikonu
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 32),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Davet Gönderildi!',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Aşağıdaki linki kopyalayarak paylaşabilirsin.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 20),
        // Kopyalanabilir link kutusu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  link,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ConstColor.primary,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                color: ConstColor.primary,
                tooltip: 'Kopyala',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link kopyalandı.'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                      margin: EdgeInsets.all(16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}

