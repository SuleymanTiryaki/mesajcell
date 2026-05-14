import 'package:dio/dio.dart';
import '../model/channel_model.dart';

abstract class IChannelService {
  final Dio dio;
  IChannelService(this.dio);

  static const String createChannelPath = '/api/v1/channels';

  /// Yeni kanal oluştur — Bearer token AppDio interceptor tarafından eklenir.
  Future<CreateChannelResponse?> createChannel(CreateChannelRequest request);
}
