class MeModel {
  final String id;
  final String fullName;
  final String presenceStatus;
  final String? profilePhotoUrl;
  final String role;
  final String? email;
  final String? gsmNumber;
  final String? orgId;

  const MeModel({
    required this.id,
    required this.fullName,
    required this.presenceStatus,
    this.profilePhotoUrl,
    required this.role,
    this.email,
    this.gsmNumber,
    this.orgId,
  });

  bool get isOrgAdmin => role == 'ORG_ADMIN';

  MeModel copyWith({
    String? fullName,
    String? presenceStatus,
    String? profilePhotoUrl,
    String? email,
    String? gsmNumber,
  }) =>
      MeModel(
        id: id,
        fullName: fullName ?? this.fullName,
        presenceStatus: presenceStatus ?? this.presenceStatus,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
        role: role,
        email: email ?? this.email,
        gsmNumber: gsmNumber ?? this.gsmNumber,
        orgId: orgId,
      );

  factory MeModel.fromJson(Map<String, dynamic> json) => MeModel(
        id: json['id']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? '',
        presenceStatus: json['presence_status']?.toString() ?? 'OFFLINE',
        profilePhotoUrl: json['profile_photo_url']?.toString(),
        role: json['role']?.toString() ?? 'MEMBER',
        email: json['email']?.toString(),
        gsmNumber: json['gsm_number']?.toString(),
        orgId: json['org_id']?.toString(),
      );
}
