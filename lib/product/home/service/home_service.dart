import 'package:dio/dio.dart';
import '../../../features/core/app_logger.dart';
import '../../channel/model/channel_member_model.dart';
import '../../channel/model/channel_model.dart';
import '../model/me_model.dart';
import '../model/org_model.dart';

class HomeService {
  final Dio _dio;
  HomeService(this._dio);

  static const _orgPath = '/api/v1/org';
  static const _mePath = '/api/v1/users/me';
  static const _dmPath = '/api/v1/channels/dm';
  static const _orgUsersPath = '/api/v1/org/users';
  static const _notificationsPath = '/api/v1/users/notifications';
  static const _searchPath = '/api/v1/search';

  static Map<String, dynamic> _m(dynamic d) {
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return Map<String, dynamic>.from(d);
    return {};
  }

  Future<OrgModel?> getOrg() async {
    try {
      final res = await _dio.get(_orgPath);
      final data = _m(res.data)['data'];
      if (data is Map) return OrgModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, st) {
      AppLogger.e('[HomeService] getOrg', error: e, stackTrace: st);
    }
    return null;
  }

  Future<MeModel?> getMe() async {
    try {
      final res = await _dio.get(_mePath);
      final data = _m(res.data)['data'];
      if (data is Map) return MeModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, st) {
      AppLogger.e('[HomeService] getMe', error: e, stackTrace: st);
    }
    return null;
  }

  Future<bool> updateMe({
    String? fullName,
    String? email,
    String? profilePhotoUrl,
    String? presenceStatus,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (email != null) body['email'] = email;
      if (profilePhotoUrl != null) body['profile_photo_url'] = profilePhotoUrl;
      if (presenceStatus != null) body['presence_status'] = presenceStatus;
      final res = await _dio.patch(_mePath, data: body);
      return _m(res.data)['success'] as bool? ?? false;
    } catch (e, st) {
      AppLogger.e('[HomeService] updateMe', error: e, stackTrace: st);
      return false;
    }
  }

  Future<ChannelModel?> createDm(String targetUserId) async {
    try {
      final res = await _dio.post(_dmPath, data: {'target_user_id': targetUserId});
      final data = _m(res.data)['data'];
      if (data is Map) return ChannelModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, st) {
      AppLogger.e('[HomeService] createDm', error: e, stackTrace: st);
    }
    return null;
  }

  Future<List<OrgUserModel>> getOrgUsers() async {
    try {
      final res = await _dio.get(_orgUsersPath);
      final raw = _m(res.data)['data'];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => OrgUserModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e, st) {
      AppLogger.e('[HomeService] getOrgUsers', error: e, stackTrace: st);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final res = await _dio.get(_notificationsPath);
      final raw = _m(res.data)['data'];
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().toList();
      }
    } catch (e, st) {
      AppLogger.e('[HomeService] getNotifications', error: e, stackTrace: st);
    }
    return [];
  }

  Future<bool> markNotificationsRead() async {
    try {
      final res = await _dio.patch('$_notificationsPath/read');
      return _m(res.data)['success'] as bool? ?? false;
    } catch (e, st) {
      AppLogger.e('[HomeService] markNotificationsRead', error: e, stackTrace: st);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> search(String q, String type, {String? channelId}) async {
    try {
      final params = <String, dynamic>{'q': q, 'type': type};
      if (channelId != null) params['channel_id'] = channelId;
      final res = await _dio.get(_searchPath, queryParameters: params);
      final raw = _m(res.data)['data'];
      if (raw is List) return raw.whereType<Map<String, dynamic>>().toList();
    } catch (e, st) {
      AppLogger.e('[HomeService] search', error: e, stackTrace: st);
    }
    return [];
  }
}
