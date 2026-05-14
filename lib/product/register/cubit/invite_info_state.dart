part of 'invite_info_cubit.dart';

enum InviteInfoStatus { initial, loading, success, error }

class InviteInfoState {
  final InviteInfoStatus status;
  final String? orgName;
  final String? inviteToken;
  final String? errorMessage;

  const InviteInfoState({
    this.status = InviteInfoStatus.initial,
    this.orgName,
    this.inviteToken,
    this.errorMessage,
  });

  InviteInfoState copyWith({
    InviteInfoStatus? status,
    String? orgName,
    String? inviteToken,
    String? errorMessage,
  }) =>
      InviteInfoState(
        status: status ?? this.status,
        orgName: orgName ?? this.orgName,
        inviteToken: inviteToken ?? this.inviteToken,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
