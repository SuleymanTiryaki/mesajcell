class ChannelMemberModel {
  final String id;
  final String fullName;
  final String role; // 'CHANNEL_ADMIN', 'MEMBER'
  final String presenceStatus; // 'ONLINE' | 'OFFLINE' | 'BUSY'

  const ChannelMemberModel({
    required this.id,
    required this.fullName,
    required this.role,
    this.presenceStatus = 'OFFLINE',
  });

  bool get isAdmin => role == 'CHANNEL_ADMIN';
  bool get isOnline => presenceStatus == 'ONLINE';

  ChannelMemberModel copyWith({String? presenceStatus}) => ChannelMemberModel(
        id: id,
        fullName: fullName,
        role: role,
        presenceStatus: presenceStatus ?? this.presenceStatus,
      );

  factory ChannelMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ChannelMemberModel(
      id: user?['id'] as String? ??
          json['user_id'] as String? ??
          json['id'] as String? ??
          '',
      fullName:
          user?['full_name'] as String? ?? json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'MEMBER',
      presenceStatus: user?['presence_status'] as String? ??
          json['presence_status'] as String? ??
          'OFFLINE',
    );
  }
}

class OrgUserModel {
  final String id;
  final String fullName;
  final String presenceStatus; // 'ONLINE' | 'OFFLINE'

  const OrgUserModel({
    required this.id,
    required this.fullName,
    this.presenceStatus = 'OFFLINE',
  });

  bool get isOnline => presenceStatus == 'ONLINE';

  factory OrgUserModel.fromJson(Map<String, dynamic> json) => OrgUserModel(
        id: json['id']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? '',
        presenceStatus: json['presence_status']?.toString() ?? 'OFFLINE',
      );
}

class ChannelMembersResponse {
  final bool success;
  final List<ChannelMemberModel> members;

  const ChannelMembersResponse({
    required this.success,
    required this.members,
  });

  factory ChannelMembersResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final data = raw is List ? raw : <dynamic>[];
    return ChannelMembersResponse(
      success: json['success'] as bool? ?? false,
      members: data
          .whereType<Map>()
          .map((e) => ChannelMemberModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class OrgUsersResponse {
  final bool success;
  final List<OrgUserModel> users;

  const OrgUsersResponse({
    required this.success,
    required this.users,
  });

  factory OrgUsersResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final data = raw is List ? raw : <dynamic>[];
    return OrgUsersResponse(
      success: json['success'] as bool? ?? false,
      users: data
          .whereType<Map>()
          .map((e) => OrgUserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
