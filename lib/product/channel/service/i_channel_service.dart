import 'package:dio/dio.dart';
import '../model/channel_member_model.dart';
import '../model/channel_message_model.dart';
import '../model/channel_model.dart';

abstract class IChannelService {
  final Dio dio;
  IChannelService(this.dio);

  static const String channelsPath = '/api/v1/channels';
  static const String publicChannelsPath = '/api/v1/channels/public';
  static const String orgUsersPath = '/api/v1/org/users';

  static String membersPath(String channelId) =>
      '/api/v1/channels/$channelId/members';

  static String inviteMemberPath(String channelId) =>
      '/api/v1/channels/$channelId/invite';

  static String messagesPath(String channelId) =>
      '/api/v1/channels/$channelId/messages';

  static String editMessagePath(String messageId) =>
      '/api/v1/messages/$messageId';

  static String reactionPath(String messageId) =>
      '/api/v1/messages/$messageId/reactions';

  static String pinPath(String channelId, String messageId) =>
      '/api/v1/channels/$channelId/pin/$messageId';

  static String pinnedMessagesPath(String channelId) =>
      '/api/v1/channels/$channelId/pinned';

  static String notificationPreferencePath(String channelId) =>
      '/api/v1/channels/$channelId/notification-preference';

  Future<CreateChannelResponse?> createChannel(CreateChannelRequest request);
  Future<GetChannelsResponse?> getChannels();
  Future<GetChannelsResponse?> getPublicChannels();
  Future<ChannelMembersResponse?> getChannelMembers(String channelId);
  Future<bool> addMember(String channelId, String userId);
  Future<bool> removeMember(String channelId, String userId);
  Future<OrgUsersResponse?> getOrgUsers();
  Future<GetMessagesResponse?> getMessages(String channelId, {int page = 1});
  Future<SendMessageResponse?> sendMessage(String channelId, String content);
  Future<bool> editMessage(String messageId, String content);
  Future<bool> deleteMessage(String messageId);
  Future<bool> addReaction(String messageId, String emoji, String channelId);
  Future<bool> pinMessage(String channelId, String messageId);
  Future<List<PinnedMessage>> getPinnedMessages(String channelId);
  Future<bool> updateNotificationPreference(String channelId, String preference);
}
