import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/app_session.dart';
import '../model/channel_member_model.dart';
import '../service/channel_service.dart';

part 'channel_members_state.dart';

class ChannelMembersCubit extends Cubit<ChannelMembersState> {
  final ChannelService _service;
  final String channelId;

  ChannelMembersCubit({required this.channelId})
      : _service = ChannelService(AppDio.create()),
        super(const ChannelMembersState());

  Future<void> fetchMembers() async {
    emit(state.copyWith(status: ChannelMembersStatus.loading));
    try {
      final response = await _service.getChannelMembers(channelId);
      final members = response?.members ?? [];
      final currentUserId = AppSession.instance.userId;
      final isAdmin = currentUserId != null &&
          members.any((m) => m.id == currentUserId && m.isAdmin);
      AppLogger.i('[ChannelMembersCubit] ${members.length} üye, admin=$isAdmin');
      emit(state.copyWith(
        status: ChannelMembersStatus.success,
        members: members,
        isCurrentUserAdmin: isAdmin,
      ));
    } catch (e, st) {
      AppLogger.e('[ChannelMembersCubit] fetchMembers hata', error: e, stackTrace: st);
      emit(state.copyWith(
        status: ChannelMembersStatus.error,
        errorMessage: 'Üyeler yüklenemedi.',
      ));
    }
  }

  Future<void> fetchOrgUsers({String query = ''}) async {
    emit(state.copyWith(orgUsersLoading: true));
    try {
      final response = await _service.getOrgUsers();
      final allUsers = response?.users ?? [];
      final memberIds = state.members.map((m) => m.id).toSet();
      var filtered = allUsers.where((u) => !memberIds.contains(u.id)).toList();
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        filtered = filtered
            .where((u) => u.fullName.toLowerCase().contains(q))
            .toList();
      }
      emit(state.copyWith(filteredOrgUsers: filtered, orgUsersLoading: false));
    } catch (e, st) {
      AppLogger.e('[ChannelMembersCubit] fetchOrgUsers hata', error: e, stackTrace: st);
      emit(state.copyWith(orgUsersLoading: false));
    }
  }

  Future<void> addMember(String userId) async {
    emit(state.copyWith(addingUserId: userId));
    try {
      final ok = await _service.addMember(channelId, userId);
      if (ok) {
        await fetchMembers();
        emit(state.copyWith(
          clearAddingUserId: true,
          lastActionMessage: 'Üye başarıyla eklendi.',
        ));
      } else {
        emit(state.copyWith(
          clearAddingUserId: true,
          lastActionMessage: 'Üye eklenemedi.',
        ));
      }
    } catch (e, st) {
      AppLogger.e('[ChannelMembersCubit] addMember hata', error: e, stackTrace: st);
      emit(state.copyWith(
        clearAddingUserId: true,
        lastActionMessage: 'Üye eklenemedi.',
      ));
    }
  }

  Future<void> removeMember(String userId) async {
    emit(state.copyWith(removingUserId: userId));
    try {
      final ok = await _service.removeMember(channelId, userId);
      if (ok) {
        final updated = state.members.where((m) => m.id != userId).toList();
        emit(state.copyWith(
          members: updated,
          clearRemovingUserId: true,
          lastActionMessage: 'Üye çıkarıldı.',
        ));
      } else {
        emit(state.copyWith(
          clearRemovingUserId: true,
          lastActionMessage: 'Üye çıkarılamadı.',
        ));
      }
    } catch (e, st) {
      AppLogger.e('[ChannelMembersCubit] removeMember hata', error: e, stackTrace: st);
      emit(state.copyWith(
        clearRemovingUserId: true,
        lastActionMessage: 'Üye çıkarılamadı.',
      ));
    }
  }

  void clearActionMessage() =>
      emit(state.copyWith(clearActionMessage: true));
}
