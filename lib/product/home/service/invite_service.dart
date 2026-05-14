import 'package:dio/dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/base_dio_service.dart';
import '../model/invite_model.dart';

class InviteService {
  final Dio dio;

  InviteService(this.dio);

  static const String invitePath = '/api/v1/org/invite';

  Future<InviteResponse?> sendInvite(InviteRequest request) async {
    try {
      AppLogger.d('[InviteService] sendInvite → ${request.toJson()}');
      final response = await dio.post(
        invitePath,
        data: request.toJson(),
      );
      final result =
          InviteResponse.fromJson(response.data as Map<String, dynamic>);
      AppLogger.i('[InviteService] Davet gönderildi: ${result.data?.inviteToken}');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    }
  }
}
