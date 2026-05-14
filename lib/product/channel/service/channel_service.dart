import 'package:dio/dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/base_dio_service.dart';
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
        IChannelService.createChannelPath,
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
}
