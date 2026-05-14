part of 'public_channel_list_cubit.dart';

enum PublicChannelListStatus { initial, loading, success, error }

class PublicChannelListState {
  final PublicChannelListStatus status;
  final List<ChannelModel> channels;
  final String? errorMessage;

  const PublicChannelListState({
    this.status = PublicChannelListStatus.initial,
    this.channels = const [],
    this.errorMessage,
  });

  PublicChannelListState copyWith({
    PublicChannelListStatus? status,
    List<ChannelModel>? channels,
    String? errorMessage,
  }) =>
      PublicChannelListState(
        status: status ?? this.status,
        channels: channels ?? this.channels,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
