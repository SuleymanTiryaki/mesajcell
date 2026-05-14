import 'package:dio/dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/base_dio_service.dart';
import '../model/channel_member_model.dart';
import '../model/channel_message_model.dart';
import '../model/channel_model.dart';
import 'i_channel_service.dart';

class ChannelService extends IChannelService {
  ChannelService(super.dio);

  @override
  Future<CreateChannelResponse?> createChannel(
      CreateChannelRequest request) async {
    try {
      AppLogger.d('[ChannelService] createChannel → ${request.toJson()}');
      final response = await dio.post(
        IChannelService.channelsPath,
        data: request.toJson(),
      );
      final result = CreateChannelResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      AppLogger.i('[ChannelService] Kanal oluşturuldu: ${result.channel?.id}');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<GetChannelsResponse?> getChannels() async {
    try {
      AppLogger.d('[ChannelService] getChannels');
      final response = await dio.get(IChannelService.channelsPath);
      final result = GetChannelsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      AppLogger.i('[ChannelService] ${result.channels.length} kanal geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<GetChannelsResponse?> getPublicChannels() async {
    try {
      AppLogger.d('[ChannelService] getPublicChannels');
      final response = await dio.get(IChannelService.publicChannelsPath);
      final result = GetChannelsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      AppLogger.i('[ChannelService] ${result.channels.length} açık kanal geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<ChannelMembersResponse?> getChannelMembers(String channelId) async {
    try {
      AppLogger.d('[ChannelService] getChannelMembers $channelId');
      final response = await dio.get(IChannelService.membersPath(channelId));
      final result = ChannelMembersResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      AppLogger.i('[ChannelService] ${result.members.length} üye geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<bool> addMember(String channelId, String userId) async {
    try {
      AppLogger.d('[ChannelService] addMember $channelId ← $userId');
      final response = await dio.post(
        IChannelService.inviteMemberPath(channelId),
        data: {'user_id': userId},
      );
      final success = (response.data as Map<String, dynamic>?)?['success'] as bool? ?? false;
      AppLogger.i('[ChannelService] addMember success=$success');
      return success;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    }
  }

  @override
  Future<bool> removeMember(String channelId, String userId) async {
    try {
      AppLogger.d('[ChannelService] removeMember $channelId/$userId');
      final response = await dio.delete(
        '${IChannelService.membersPath(channelId)}/$userId',
      );
      final success = (response.data as Map<String, dynamic>?)?['success'] as bool? ?? false;
      AppLogger.i('[ChannelService] removeMember success=$success');
      return success;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    }
  }

  @override
  Future<OrgUsersResponse?> getOrgUsers() async {
    try {
      AppLogger.d('[ChannelService] getOrgUsers');
      final response = await dio.get(IChannelService.orgUsersPath);
      final result = OrgUsersResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      AppLogger.i('[ChannelService] ${result.users.length} org kullanıcısı geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<GetMessagesResponse?> getMessages(String channelId) async {
    try {
      AppLogger.d('[ChannelService] getMessages $channelId');
      final response =
          await dio.get(IChannelService.messagesPath(channelId));
      final result = GetMessagesResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      AppLogger.i('[ChannelService] ${result.messages.length} mesaj geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }

  @override
  Future<SendMessageResponse?> sendMessage(
      String channelId, String content) async {
    try {
      AppLogger.d('[ChannelService] sendMessage $channelId → $content');
      final response = await dio.post(
        IChannelService.messagesPath(channelId),
        data: {'content': content},
      );
      final result = SendMessageResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      AppLogger.i('[ChannelService] mesaj gönderildi: ${result.message?.id}');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }
}

