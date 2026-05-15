class MeModel {
  final String id;
  final String fullName;
  final String presenceStatus;
  final String? profilePhotoUrl;
  final String role;

  const MeModel({
    required this.id,
    required this.fullName,
    required this.presenceStatus,
    this.profilePhotoUrl,
    required this.role,
  });

  bool get isOrgAdmin => role == 'ORG_ADMIN';

  MeModel copyWith({
    String? fullName,
    String? presenceStatus,
    String? profilePhotoUrl,
  }) =>
      MeModel(
        id: id,
        fullName: fullName ?? this.fullName,
        presenceStatus: presenceStatus ?? this.presenceStatus,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
        role: role,
      );

  factory MeModel.fromJson(Map<String, dynamic> json) => MeModel(
        id: json['id']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? '',
        presenceStatus: json['presence_status']?.toString() ?? 'OFFLINE',
        profilePhotoUrl: json['profile_photo_url']?.toString(),
        role: json['role']?.toString() ?? 'MEMBER',
      );
}
