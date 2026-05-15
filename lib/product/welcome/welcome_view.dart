import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/utility/const/constant_color.dart';
import '../register/cubit/invite_info_cubit.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InviteInfoCubit(),
      child: const _WelcomeBody(),
    );
  }
}

class _WelcomeBody extends StatelessWidget {
  const _WelcomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocListener<InviteInfoCubit, InviteInfoState>(
      listener: (context, state) {
        if (state.status == InviteInfoStatus.success) {
          Navigator.of(context).pop(); // modal'ı kapat
          context.push(
            '/register?invite_token=${state.inviteToken}&org_name=${Uri.encodeComponent(state.orgName ?? '')}',
          );
        }
        if (state.status == InviteInfoStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Hata oluştu.')),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo / başlık
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ConstColor.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.chat_bubble_rounded,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 24),
                Text(
                  'MesajCell',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ekibinizle güvenli, hızlı iletişim',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                // Butonlar
                FilledButton(
                  onPressed: () => context.push('/register-admin'),
                  style: FilledButton.styleFrom(
                    backgroundColor: ConstColor.primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Şirket Kur',
                      style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/login'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                  child: const Text('Giriş Yap',
                      style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _showInviteModal(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text(
                    'Davet Linki ile Katıl',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInviteModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<InviteInfoCubit>(),
        child: const _InviteLinkSheet(),
      ),
    );
  }
}

class _InviteLinkSheet extends StatefulWidget {
  const _InviteLinkSheet();

  @override
  State<_InviteLinkSheet> createState() => _InviteLinkSheetState();
}

class _InviteLinkSheetState extends State<_InviteLinkSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Expanded(
              child: Text('Davet Linki',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: 'https://mesajcell.app/invite?token=...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<InviteInfoCubit, InviteInfoState>(
            builder: (context, state) {
              final loading = state.status == InviteInfoStatus.loading;
              return FilledButton(
                onPressed: loading
                    ? null
                    : () => context
                        .read<InviteInfoCubit>()
                        .fetchFromLink(_ctrl.text),
                style: FilledButton.styleFrom(
                  backgroundColor: ConstColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Devam Et'),
              );
            },
          ),
        ],
      ),
    );
  }
}
