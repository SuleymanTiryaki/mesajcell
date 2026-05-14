// ─── Request ──────────────────────────────────────────────────────────────────

class InviteRequest {
  final String email;
  final String gsmNumber;

  const InviteRequest({required this.email, required this.gsmNumber});

  Map<String, dynamic> toJson() => {
        'email': email,
        'gsm_number': gsmNumber,
      };
}

// ─── Response ─────────────────────────────────────────────────────────────────

class InviteData {
  final String inviteToken;
  final String inviteLink;
  final String expiresAt;

  const InviteData({
    required this.inviteToken,
    required this.inviteLink,
    required this.expiresAt,
  });

  factory InviteData.fromJson(Map<String, dynamic> json) => InviteData(
        inviteToken: json['invite_token'] as String? ?? '',
        inviteLink: json['invite_link'] as String? ?? '',
        expiresAt: json['expires_at'] as String? ?? '',
      );
}

class InviteResponse {
  final bool success;
  final String? message;
  final InviteData? data;

  const InviteResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory InviteResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>?;
    return InviteResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: d != null ? InviteData.fromJson(d) : null,
    );
  }
}
