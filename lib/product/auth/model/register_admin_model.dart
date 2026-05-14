class RegisterAdminRequest {
  final String gsmNumber;
  final String fullName;
  final String email;
  final String password;
  final String orgName;
  final String orgDomain;
  final String? orgLogo;

  const RegisterAdminRequest({
    required this.gsmNumber,
    required this.fullName,
    required this.email,
    required this.password,
    required this.orgName,
    required this.orgDomain,
    this.orgLogo,
  });

  Map<String, dynamic> toJson() => {
        'gsm_number': gsmNumber,
        'full_name': fullName,
        'email': email,
        'password': password,
        'org_name': orgName,
        'org_domain': orgDomain,
        if (orgLogo != null && orgLogo!.isNotEmpty) 'org_logo': orgLogo,
      };
}

class RegisterAdminResponse {
  final bool success;
  final String? message;
  final String? userId;
  final String? orgId;

  const RegisterAdminResponse({
    required this.success,
    this.message,
    this.userId,
    this.orgId,
  });

  factory RegisterAdminResponse.fromJson(Map<String, dynamic> json) =>
      RegisterAdminResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String?,
        userId: json['user_id'] as String?,
        orgId: json['org_id'] as String?,
      );
}
