part of 'channel_list_cubit.dart';

enum ChannelListStatus { initial, loading, success, error }

class ChannelListState {
  final ChannelListStatus status;
  final List<ChannelModel> channels;
  final String? errorMessage;
  final Map<String, int> unreadCounts; // channelId → unread count
  final String? activeChannelId;

  const ChannelListState({
    this.status = ChannelListStatus.initial,
    this.channels = const [],
    this.errorMessage,
    this.unreadCounts = const {},
    this.activeChannelId,
  });

  int unreadFor(String channelId) => unreadCounts[channelId] ?? 0;

  ChannelListState copyWith({
    ChannelListStatus? status,
    List<ChannelModel>? channels,
    String? errorMessage,
    Map<String, int>? unreadCounts,
    String? activeChannelId,
    bool clearActiveChannel = false,
  }) =>
      ChannelListState(
        status: status ?? this.status,
        channels: channels ?? this.channels,
        errorMessage: errorMessage ?? this.errorMessage,
        unreadCounts: unreadCounts ?? this.unreadCounts,
        activeChannelId:
            clearActiveChannel ? null : (activeChannelId ?? this.activeChannelId),
      );
}
