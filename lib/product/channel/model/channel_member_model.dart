class ChannelMemberModel {
  final String id;
  final String fullName;
  final String role; // 'CHANNEL_ADMIN', 'MEMBER'

  const ChannelMemberModel({
    required this.id,
    required this.fullName,
    required this.role,
  });

  bool get isAdmin => role == 'CHANNEL_ADMIN';

  factory ChannelMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ChannelMemberModel(
      id: user?['id'] as String? ?? json['user_id'] as String? ?? json['id'] as String? ?? '',
      fullName: user?['full_name'] as String? ?? json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'MEMBER',
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
        id: json['id'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        presenceStatus: json['presence_status'] as String? ?? 'OFFLINE',
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
    final data = json['data'] as List<dynamic>? ?? [];
    return ChannelMembersResponse(
      success: json['success'] as bool? ?? false,
      members: data
          .map((e) => ChannelMemberModel.fromJson(e as Map<String, dynamic>))
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
    final data = json['data'] as List<dynamic>? ?? [];
    return OrgUsersResponse(
      success: json['success'] as bool? ?? false,
      users: data
          .map((e) => OrgUserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
