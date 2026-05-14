class InviteInfoResponse {
  final bool success;
  final String? orgName;
  final String? message;

  const InviteInfoResponse({
    required this.success,
    this.orgName,
    this.message,
  });

  factory InviteInfoResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return InviteInfoResponse(
      success: json['success'] as bool? ?? false,
      orgName: data?['org_name'] as String?,
      message: json['message'] as String?,
    );
  }
}
