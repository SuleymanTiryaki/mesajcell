part of 'message_cubit.dart';

enum MessageStatus { initial, loading, success, error }

class MessageState {
  final MessageStatus status;
  final List<MessageModel> messages;
  final bool sending;
  final String? errorMessage;

  const MessageState({
    this.status = MessageStatus.initial,
    this.messages = const [],
    this.sending = false,
    this.errorMessage,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<MessageModel>? messages,
    bool? sending,
    String? errorMessage,
  }) =>
      MessageState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        sending: sending ?? this.sending,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
