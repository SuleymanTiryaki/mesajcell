import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/utility/const/constant_color.dart';
import '../cubit/create_channel_cubit.dart';
import '../model/channel_model.dart';

class CreateChannelView extends StatelessWidget {
  const CreateChannelView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateChannelCubit(),
      child: const _CreateChannelBody(),
    );
  }
}

class _CreateChannelBody extends StatefulWidget {
  const _CreateChannelBody();

  @override
  State<_CreateChannelBody> createState() => _CreateChannelBodyState();
}

class _CreateChannelBodyState extends State<_CreateChannelBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  ChannelType _selectedType = ChannelType.public;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreateChannelCubit>().createChannel(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          type: _selectedType,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateChannelCubit, CreateChannelState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == CreateChannelStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '"${state.channel?.name ?? ''}" kanalı oluşturuldu.',
              ),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.of(context).pop();
          return;
        }
        if (state.status == CreateChannelStatus.error &&
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
          context.read<CreateChannelCubit>().clearError();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yeni Kanal'),
          leading: const CloseButton(),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kanal adı
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Kanal Adı',
                      prefixIcon: Icon(Icons.tag),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Kanal adı boş bırakılamaz.'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Açıklama
                  TextFormField(
                    controller: _descController,
                    textInputAction: TextInputAction.next,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      prefixIcon: Icon(Icons.info_outline),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Açıklama boş bırakılamaz.'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Kanal tipi
                  Text(
                    'Kanal Tipi',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  _TypeSelector(
                    selected: _selectedType,
                    onChanged: (t) => setState(() => _selectedType = t),
                  ),
                  const SizedBox(height: 32),

                  // Oluştur butonu
                  BlocBuilder<CreateChannelCubit, CreateChannelState>(
                    buildWhen: (p, c) => p.status != c.status,
                    builder: (context, state) {
                      final isLoading =
                          state.status == CreateChannelStatus.loading;
                      return FilledButton(
                        onPressed: isLoading ? null : _submit,
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
                                'Kanal Oluştur',
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

// ─── Kanal tipi seçici ────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final ChannelType selected;
  final ValueChanged<ChannelType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const types = [ChannelType.public, ChannelType.private];
    return Row(
      children: types.map((type) {
        final isSelected = selected == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type == ChannelType.public
                        ? Icons.public
                        : Icons.lock_outline,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(type == ChannelType.public ? 'Herkese Açık' : 'Özel'),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(type),
              selectedColor: ConstColor.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
