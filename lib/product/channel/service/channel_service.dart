import 'package:dio/dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/base_dio_service.dart';
import '../model/channel_member_model.dart';
import '../model/channel_message_model.dart';
import '../model/channel_model.dart';
import 'i_channel_service.dart';

class ChannelService extends IChannelService {
  ChannelService(super.dio);

  // Dio'nun response.data'sı bazen Map<dynamic,dynamic> gelir —
  // bu helper her durumda Map<String,dynamic>'e çevirir.
  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    AppLogger.w('[ChannelService] Beklenmedik response tipi: ${data.runtimeType}');
    return {};
  }

  @override
  Future<CreateChannelResponse?> createChannel(
      CreateChannelRequest request) async {
    try {
      AppLogger.d('[ChannelService] createChannel → ${request.toJson()}');
      final response = await dio.post(
        IChannelService.channelsPath,
        data: request.toJson(),
      );
      final result = CreateChannelResponse.fromJson(_toMap(response.data));
      AppLogger.i('[ChannelService] Kanal oluşturuldu: ${result.channel?.id}');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    } catch (e, st) {
      AppLogger.e('[ChannelService] createChannel parse hatası', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<GetChannelsResponse?> getChannels() async {
    try {
      AppLogger.d('[ChannelService] getChannels');
      final response = await dio.get(IChannelService.channelsPath);
      final result = GetChannelsResponse.fromJson(_toMap(response.data));
      AppLogger.i('[ChannelService] ${result.channels.length} kanal geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    } catch (e, st) {
      AppLogger.e('[ChannelService] getChannels parse hatası', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<GetChannelsResponse?> getPublicChannels() async {
    try {
      AppLogger.d('[ChannelService] getPublicChannels');
      final response = await dio.get(IChannelService.publicChannelsPath);
      final result = GetChannelsResponse.fromJson(_toMap(response.data));
      AppLogger.i('[ChannelService] ${result.channels.length} açık kanal geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    } catch (e, st) {
      AppLogger.e('[ChannelService] getPublicChannels parse hatası', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<ChannelMembersResponse?> getChannelMembers(String channelId) async {
    try {
      AppLogger.d('[ChannelService] getChannelMembers $channelId');
      final response = await dio.get(IChannelService.membersPath(channelId));
      final result = ChannelMembersResponse.fromJson(_toMap(response.data));
      AppLogger.i('[ChannelService] ${result.members.length} üye geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    } catch (e, st) {
      AppLogger.e('[ChannelService] getChannelMembers parse hatası', error: e, stackTrace: st);
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
      final map = _toMap(response.data);
      final success = map['success'] as bool? ?? false;
      AppLogger.i('[ChannelService] addMember success=$success');
      return success;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    } catch (e, st) {
      AppLogger.e('[ChannelService] addMember parse hatası', error: e, stackTrace: st);
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
      final map = _toMap(response.data);
      final success = map['success'] as bool? ?? false;
      AppLogger.i('[ChannelService] removeMember success=$success');
      return success;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    } catch (e, st) {
      AppLogger.e('[ChannelService] removeMember parse hatası', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<OrgUsersResponse?> getOrgUsers() async {
    try {
      AppLogger.d('[ChannelService] getOrgUsers');
      final response = await dio.get(IChannelService.orgUsersPath);
      final result = OrgUsersResponse.fromJson(_toMap(response.data));
      AppLogger.i('[ChannelService] ${result.users.length} org kullanıcısı geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    } catch (e, st) {
      AppLogger.e('[ChannelService] getOrgUsers parse hatası', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<GetMessagesResponse?> getMessages(String channelId, {int page = 1}) async {
    try {
      AppLogger.d('[ChannelService] getMessages $channelId page=$page');
      final response = await dio.get(
        IChannelService.messagesPath(channelId),
        queryParameters: {'page': page},
      );
      final result = GetMessagesResponse.fromJson(_toMap(response.data));
      AppLogger.i('[ChannelService] ${result.messages.length} mesaj geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    } catch (e, st) {
      AppLogger.e('[ChannelService] getMessages parse hatası', error: e, stackTrace: st);
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
      final result = SendMessageResponse.fromJson(_toMap(response.data));
      AppLogger.i('[ChannelService] mesaj gönderildi: ${result.message?.id}');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    } catch (e, st) {
      AppLogger.e('[ChannelService] sendMessage parse hatası', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<bool> editMessage(String messageId, String content) async {
    try {
      final response = await dio.patch(
        IChannelService.editMessagePath(messageId),
        data: {'content': content},
      );
      return _toMap(response.data)['success'] as bool? ?? false;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    } catch (e, st) {
      AppLogger.e('[ChannelService] editMessage hatası', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> deleteMessage(String messageId) async {
    try {
      final response = await dio.delete(IChannelService.editMessagePath(messageId));
      return _toMap(response.data)['success'] as bool? ?? false;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    } catch (e, st) {
      AppLogger.e('[ChannelService] deleteMessage hatası', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> addReaction(String messageId, String emoji, String channelId) async {
    try {
      final response = await dio.post(
        IChannelService.reactionPath(messageId),
        data: {'emoji': emoji, 'channel_id': channelId},
      );
      return _toMap(response.data)['success'] as bool? ?? false;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    } catch (e, st) {
      AppLogger.e('[ChannelService] addReaction hatası', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> pinMessage(String channelId, String messageId) async {
    try {
      final response = await dio.post(IChannelService.pinPath(channelId, messageId));
      return _toMap(response.data)['success'] as bool? ?? false;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    } catch (e, st) {
      AppLogger.e('[ChannelService] pinMessage hatası', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<List<PinnedMessage>> getPinnedMessages(String channelId) async {
    try {
      final response =
          await dio.get(IChannelService.pinnedMessagesPath(channelId));
      final raw = _toMap(response.data)['data'];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => PinnedMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return [];
    } catch (e, st) {
      AppLogger.e('[ChannelService] getPinnedMessages hatası',
          error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> updateNotificationPreference(
      String channelId, String preference) async {
    try {
      AppLogger.d(
          '[ChannelService] updateNotificationPreference $channelId → $preference');
      final response = await dio.patch(
        IChannelService.notificationPreferencePath(channelId),
        data: {'preference': preference},
      );
      return _toMap(response.data)['success'] as bool? ?? false;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    } catch (e, st) {
      AppLogger.e('[ChannelService] updateNotificationPreference hatası',
          error: e, stackTrace: st);
      return false;
    }
  }
}
