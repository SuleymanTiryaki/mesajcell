import 'package:dio/dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/base_dio_service.dart';
import '../model/notification_model.dart';

class NotificationService {
  final Dio dio;

  NotificationService(this.dio);

  static const _notificationsPath = '/api/v1/users/notifications';
  static const _markReadPath = '/api/v1/users/notifications/read';

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Future<GetNotificationsResponse?> getNotifications() async {
    try {
      AppLogger.d('[NotificationService] getNotifications');
      final response = await dio.get(_notificationsPath);
      final result =
          GetNotificationsResponse.fromJson(_toMap(response.data));
      AppLogger.i(
          '[NotificationService] ${result.notifications.length} bildirim geldi');
      return result;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return null;
    } catch (e, st) {
      AppLogger.e('[NotificationService] getNotifications hatası',
          error: e, stackTrace: st);
      return null;
    }
  }

  Future<bool> markAllRead() async {
    try {
      AppLogger.d('[NotificationService] markAllRead');
      final response = await dio.patch(_markReadPath);
      return _toMap(response.data)['success'] as bool? ?? false;
    } on DioException catch (e) {
      BaseDioService.service.handleDioError(e);
      return false;
    } catch (e, st) {
      AppLogger.e('[NotificationService] markAllRead hatası',
          error: e, stackTrace: st);
      return false;
    }
  }
}
