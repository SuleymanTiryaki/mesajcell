part of 'channel_members_cubit.dart';

enum ChannelMembersStatus { initial, loading, success, error }

class ChannelMembersState {
  final ChannelMembersStatus status;
  final List<ChannelMemberModel> members;
  final List<OrgUserModel> filteredOrgUsers;
  final bool isCurrentUserAdmin;
  final String? errorMessage;
  final bool orgUsersLoading;
  final String? addingUserId;
  final String? removingUserId;
  final String? lastActionMessage;
  final String? typingUserName; // "Zeynep yazıyor..."

  const ChannelMembersState({
    this.status = ChannelMembersStatus.initial,
    this.members = const [],
    this.filteredOrgUsers = const [],
    this.isCurrentUserAdmin = false,
    this.errorMessage,
    this.orgUsersLoading = false,
    this.addingUserId,
    this.removingUserId,
    this.lastActionMessage,
    this.typingUserName,
  });

  ChannelMembersState copyWith({
    ChannelMembersStatus? status,
    List<ChannelMemberModel>? members,
    List<OrgUserModel>? filteredOrgUsers,
    bool? isCurrentUserAdmin,
    String? errorMessage,
    bool? orgUsersLoading,
    String? addingUserId,
    String? removingUserId,
    String? lastActionMessage,
    String? typingUserName,
    bool clearRemovingUserId = false,
    bool clearAddingUserId = false,
    bool clearError = false,
    bool clearActionMessage = false,
    bool clearTyping = false,
  }) =>
      ChannelMembersState(
        status: status ?? this.status,
        members: members ?? this.members,
        filteredOrgUsers: filteredOrgUsers ?? this.filteredOrgUsers,
        isCurrentUserAdmin: isCurrentUserAdmin ?? this.isCurrentUserAdmin,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        orgUsersLoading: orgUsersLoading ?? this.orgUsersLoading,
        addingUserId:
            clearAddingUserId ? null : (addingUserId ?? this.addingUserId),
        removingUserId:
            clearRemovingUserId ? null : (removingUserId ?? this.removingUserId),
        lastActionMessage: clearActionMessage
            ? null
            : (lastActionMessage ?? this.lastActionMessage),
        typingUserName:
            clearTyping ? null : (typingUserName ?? this.typingUserName),
      );
}
