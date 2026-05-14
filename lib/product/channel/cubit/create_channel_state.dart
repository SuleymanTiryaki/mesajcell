part of 'create_channel_cubit.dart';

enum CreateChannelStatus { initial, loading, success, error }

class CreateChannelState {
  final CreateChannelStatus status;
  final String? errorMessage;
  final ChannelModel? channel;

  const CreateChannelState({
    this.status = CreateChannelStatus.initial,
    this.errorMessage,
    this.channel,
  });

  CreateChannelState copyWith({
    CreateChannelStatus? status,
    String? errorMessage,
    ChannelModel? channel,
  }) =>
      CreateChannelState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        channel: channel ?? this.channel,
      );
}
