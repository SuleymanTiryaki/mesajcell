import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/app_session.dart';
import '../../../features/core/socket_service.dart';
import '../model/channel_model.dart';
import '../service/channel_service.dart';

part 'channel_list_state.dart';

class ChannelListCubit extends Cubit<ChannelListState> {
  final ChannelService service;
  StreamSubscription<Map<String, dynamic>>? _socketSub;

  ChannelListCubit()
      : service = ChannelService(AppDio.create()),
        super(const ChannelListState()) {
    _listenSocket();
  }

  void _listenSocket() {
    _socketSub = SocketService.instance.onMessageNew.listen((data) {
      final channelId = data['channel_id'] as String? ?? '';
      if (channelId.isEmpty) return;
      if (channelId == state.activeChannelId) return;

      final channel = state.channels.cast<ChannelModel?>().firstWhere(
            (c) => c?.id == channelId,
            orElse: () => null,
          );
      final pref = channel?.notificationPreference ?? 'ALL';
      if (pref == 'MUTED') return;
      if (pref == 'MENTIONS_ONLY') {
        final myId = AppSession.instance.userId ?? '';
        final content = data['content'] as String? ?? '';
        if (myId.isEmpty || !content.contains(myId)) return;
      }

      final counts = Map<String, int>.from(state.unreadCounts);
      counts[channelId] = (counts[channelId] ?? 0) + 1;
      emit(state.copyWith(unreadCounts: counts));
    });
  }

  Future<void> fetchChannels() async {
    emit(state.copyWith(status: ChannelListStatus.loading));

    final response = await service.getChannels();

    if (response == null) {
      emit(state.copyWith(
        status: ChannelListStatus.error,
        errorMessage: 'Sunucuya bağlanılamadı.',
      ));
      return;
    }

    if (response.success) {
      AppLogger.i(
          '[ChannelListCubit] ${response.channels.length} kanal yüklendi');
      emit(state.copyWith(
        status: ChannelListStatus.success,
        channels: response.channels,
      ));
    } else {
      emit(state.copyWith(
        status: ChannelListStatus.error,
        errorMessage: 'Kanallar yüklenemedi.',
      ));
    }
  }

  /// Kanala girilince çağır — badge sıfırlanır.
  void setActiveChannel(String channelId) {
    final counts = Map<String, int>.from(state.unreadCounts);
    counts.remove(channelId);
    emit(state.copyWith(activeChannelId: channelId, unreadCounts: counts));
  }

  /// Kanaldan çıkılınca çağır.
  void clearActiveChannel() {
    emit(state.copyWith(clearActiveChannel: true));
  }

  /// Bildirim tercihini güncelle (ALL / MENTIONS_ONLY / MUTED).
  Future<void> updateNotificationPreference(
      String channelId, String preference) async {
    final ok =
        await service.updateNotificationPreference(channelId, preference);
    if (!ok) return;
    final updated = state.channels
        .map((c) =>
            c.id == channelId ? c.copyWith(notificationPreference: preference) : c)
        .toList();
    emit(state.copyWith(channels: updated));
    AppLogger.i(
        '[ChannelListCubit] notif pref updated $channelId → $preference');
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    return super.close();
  }
}
