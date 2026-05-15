import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/core/app_dio.dart';
import '../../../features/core/app_logger.dart';
import '../../../features/core/app_session.dart';
import '../../../features/core/socket_service.dart';
import '../../channel/model/channel_member_model.dart';
import '../../channel/model/channel_model.dart';
import '../../channel/service/channel_service.dart';
import '../model/me_model.dart';
import '../model/org_model.dart';
import '../service/home_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService _homeService;
  final ChannelService _channelService;

  StreamSubscription<Map<String, dynamic>>? _msgNewSub;
  StreamSubscription<Map<String, dynamic>>? _statusSub;

  HomeCubit()
      : _homeService = HomeService(AppDio.create()),
        _channelService = ChannelService(AppDio.create()),
        super(const HomeState());

  Future<void> init() async {
    emit(state.copyWith(status: HomeStatus.loading));

    OrgModel? org;
    GetChannelsResponse? channelsResp;
    List<OrgUserModel> orgUsers = [];
    MeModel? me;

    try {
      await Future.wait([
        _homeService.getOrg().then((v) => org = v),
        _channelService.getChannels().then((v) => channelsResp = v),
        _homeService.getOrgUsers().then((v) => orgUsers = v),
        _homeService.getMe().then((v) => me = v),
      ]);
    } catch (e, st) {
      AppLogger.e('[HomeCubit] init hata', error: e, stackTrace: st);
    }

    if (!isClosed) {
      emit(state.copyWith(
        status: HomeStatus.success,
        org: org,
        channels: channelsResp?.channels ?? [],
        orgUsers: orgUsers,
        me: me,
      ));
    }

    _subscribeToSocket();

    // Mevcut tüm kanallara socket room'una gir
    for (final ch in (channelsResp?.channels ?? [])) {
      SocketService.instance.joinChannel(ch.id);
    }

    // Giriş yapınca presence güncelle
    SocketService.instance.sendStatus('ONLINE');
  }

  void _subscribeToSocket() {
    // Aktif olmayan kanalın okunmamış sayacını artır
    _msgNewSub = SocketService.instance.onMessageNew.listen((data) {
      final channelId = data['channel_id']?.toString();
      if (channelId == null || channelId == state.activeChannel?.id) return;
      final updated = Map<String, int>.from(state.unreadCounts);
      updated[channelId] = (updated[channelId] ?? 0) + 1;

      // Mention kontrolü
      final myId = AppSession.instance.userId;
      if (myId != null) {
        final content = data['content']?.toString() ?? '';
        if (content.contains(myId)) {
          final senderName = data['sender_name']?.toString() ?? '';
          AppLogger.i('[HomeCubit] Mention: $senderName seni etiketledi');
        }
      }

      if (!isClosed) emit(state.copyWith(unreadCounts: updated));
    });

    // Presence güncellemeleri
    _statusSub = SocketService.instance.onStatus.listen((data) {
      final userId = data['user_id']?.toString();
      final status = data['presence_status']?.toString();
      if (userId == null || status == null) return;
      final updated = state.orgUsers
          .map((u) => u.id == userId
              ? OrgUserModel(id: u.id, fullName: u.fullName, presenceStatus: status)
              : u)
          .toList();
      if (!isClosed) emit(state.copyWith(orgUsers: updated));
    });
  }

  void setActiveChannel(ChannelModel channel) {
    if (isClosed) return;
    final counts = Map<String, int>.from(state.unreadCounts)..remove(channel.id);
    emit(state.copyWith(activeChannel: channel, unreadCounts: counts));
  }

  Future<void> createDm(String targetUserId) async {
    final channel = await _homeService.createDm(targetUserId);
    if (channel == null || isClosed) return;
    final exists = state.channels.any((c) => c.id == channel.id);
    final updated = exists ? state.channels : [channel, ...state.channels];
    final counts = Map<String, int>.from(state.unreadCounts)..remove(channel.id);
    if (!exists) SocketService.instance.joinChannel(channel.id);
    emit(state.copyWith(
      activeChannel: channel,
      channels: updated,
      unreadCounts: counts,
    ));
  }

  Future<void> refreshChannels() async {
    final resp = await _channelService.getChannels();
    if (resp == null || isClosed) return;
    // Listeye yeni gelen kanalların socket room'una gir
    final existingIds = state.channels.map((c) => c.id).toSet();
    for (final ch in resp.channels) {
      if (!existingIds.contains(ch.id)) {
        SocketService.instance.joinChannel(ch.id);
      }
    }
    emit(state.copyWith(channels: resp.channels));
  }

  Future<void> updatePresence(String status) async {
    await _homeService.updateMe(presenceStatus: status);
    SocketService.instance.sendStatus(status);
    if (state.me != null && !isClosed) {
      emit(state.copyWith(me: state.me!.copyWith(presenceStatus: status)));
    }
  }

  Future<void> updateMe({String? fullName, String? profilePhotoUrl}) async {
    final ok = await _homeService.updateMe(
      fullName: fullName,
      profilePhotoUrl: profilePhotoUrl,
    );
    if (ok && state.me != null && !isClosed) {
      emit(state.copyWith(
        me: state.me!.copyWith(
          fullName: fullName,
          profilePhotoUrl: profilePhotoUrl,
        ),
      ));
    }
  }

  @override
  Future<void> close() {
    _msgNewSub?.cancel();
    _statusSub?.cancel();
    return super.close();
  }
}
