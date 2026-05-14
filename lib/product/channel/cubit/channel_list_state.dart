part of 'channel_list_cubit.dart';

enum ChannelListStatus { initial, loading, success, error }

class ChannelListState {
  final ChannelListStatus status;
  final List<ChannelModel> channels;
  final String? errorMessage;

  const ChannelListState({
    this.status = ChannelListStatus.initial,
    this.channels = const [],
    this.errorMessage,
  });

  ChannelListState copyWith({
    ChannelListStatus? status,
    List<ChannelModel>? channels,
    String? errorMessage,
  }) =>
      ChannelListState(
        status: status ?? this.status,
        channels: channels ?? this.channels,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
