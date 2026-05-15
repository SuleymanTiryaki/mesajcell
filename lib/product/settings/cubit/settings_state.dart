part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, error }

class SettingsState {
  final SettingsStatus status;
  final MeModel? me;
  final bool saving;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.me,
    this.saving = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    MeModel? me,
    bool? saving,
    String? errorMessage,
  }) =>
      SettingsState(
        status: status ?? this.status,
        me: me ?? this.me,
        saving: saving ?? this.saving,
        errorMessage: errorMessage,
      );
}
