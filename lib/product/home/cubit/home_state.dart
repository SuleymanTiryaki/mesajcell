part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState {
  final HomeStatus status;
  final OrgModel? org;
  final List<ChannelModel> channels;
  final List<OrgUserModel> orgUsers;
  final MeModel? me;
  final ChannelModel? activeChannel;
  final Map<String, int> unreadCounts;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.org,
    this.channels = const [],
    this.orgUsers = const [],
    this.me,
    this.activeChannel,
    this.unreadCounts = const {},
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    OrgModel? org,
    List<ChannelModel>? channels,
    List<OrgUserModel>? orgUsers,
    MeModel? me,
    ChannelModel? activeChannel,
    Map<String, int>? unreadCounts,
    String? errorMessage,
    bool clearActiveChannel = false,
  }) =>
      HomeState(
        status: status ?? this.status,
        org: org ?? this.org,
        channels: channels ?? this.channels,
        orgUsers: orgUsers ?? this.orgUsers,
        me: me ?? this.me,
        activeChannel:
            clearActiveChannel ? null : (activeChannel ?? this.activeChannel),
        unreadCounts: unreadCounts ?? this.unreadCounts,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
