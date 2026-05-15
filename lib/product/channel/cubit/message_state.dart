part of 'message_cubit.dart';

enum MessageStatus { initial, loading, success, error }

class MessageState {
  final MessageStatus status;
  final List<MessageModel> messages;
  final bool sending;
  final bool loadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;
  final List<PinnedMessage> pinnedMessages;
  final bool loadingPinned;

  const MessageState({
    this.status = MessageStatus.initial,
    this.messages = const [],
    this.sending = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
    this.pinnedMessages = const [],
    this.loadingPinned = false,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<MessageModel>? messages,
    bool? sending,
    bool? loadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    List<PinnedMessage>? pinnedMessages,
    bool? loadingPinned,
  }) =>
      MessageState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        sending: sending ?? this.sending,
        loadingMore: loadingMore ?? this.loadingMore,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        errorMessage: errorMessage ?? this.errorMessage,
        pinnedMessages: pinnedMessages ?? this.pinnedMessages,
        loadingPinned: loadingPinned ?? this.loadingPinned,
      );
}
