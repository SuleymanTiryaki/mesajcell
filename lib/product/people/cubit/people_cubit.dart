import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/app_session.dart';
import '../../channel/model/channel_member_model.dart';
import '../../channel/model/channel_model.dart';
import '../../home/service/home_service.dart';

part 'people_state.dart';

class PeopleCubit extends Cubit<PeopleState> {
  final HomeService _service;

  PeopleCubit()
      : _service = HomeService(AppDio.create()),
        super(const PeopleState());

  Future<void> fetchUsers() async {
    emit(state.copyWith(status: PeopleStatus.loading));
    try {
      final users = await _service.getOrgUsers();
      // Kendimizi listeden çıkar
      final myId = AppSession.instance.userId ?? '';
      final filtered = users.where((u) => u.id != myId).toList();
      emit(state.copyWith(status: PeopleStatus.success, users: filtered, allUsers: filtered));
    } catch (e, st) {
      AppLogger.e('[PeopleCubit] fetchUsers', error: e, stackTrace: st);
      emit(state.copyWith(status: PeopleStatus.error, errorMessage: 'Kullanıcılar yüklenemedi.'));
    }
  }

  void filterUsers(String query) {
    final q = query.toLowerCase();
    final filtered = q.isEmpty
        ? state.allUsers
        : state.allUsers.where((u) => u.fullName.toLowerCase().contains(q)).toList();
    emit(state.copyWith(users: filtered, query: query));
  }

  Future<ChannelModel?> createDm(String targetUserId) async {
    emit(state.copyWith(creatingDm: true));
    try {
      final channel = await _service.createDm(targetUserId);
      emit(state.copyWith(creatingDm: false));
      return channel;
    } catch (e, st) {
      AppLogger.e('[PeopleCubit] createDm', error: e, stackTrace: st);
      emit(state.copyWith(creatingDm: false, errorMessage: 'Sohbet başlatılamadı.'));
      return null;
    }
  }
}
