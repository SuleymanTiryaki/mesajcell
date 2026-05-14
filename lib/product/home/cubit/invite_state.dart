part of 'invite_cubit.dart';

enum InviteStatus { initial, loading, success, error }

class InviteState {
  final InviteStatus status;
  final String? errorMessage;
  final InviteData? inviteData;

  const InviteState({
    this.status = InviteStatus.initial,
    this.errorMessage,
    this.inviteData,
  });

  InviteState copyWith({
    InviteStatus? status,
    String? errorMessage,
    InviteData? inviteData,
  }) =>
      InviteState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        inviteData: inviteData ?? this.inviteData,
      );
}
