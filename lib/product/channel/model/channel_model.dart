enum ChannelType { public, private }

extension ChannelTypeX on ChannelType {
  String get value => name.toUpperCase(); // 'PUBLIC' / 'PRIVATE'
  static ChannelType fromString(String v) =>
      v.toUpperCase() == 'PRIVATE' ? ChannelType.private : ChannelType.public;
}

// ─── Request ──────────────────────────────────────────────────────────────────

class CreateChannelRequest {
  final String name;
  final String description;
  final ChannelType type;
  final String? iconUrl;

  const CreateChannelRequest({
    required this.name,
    required this.description,
    this.type = ChannelType.public,
    this.iconUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'type': type.value,
        'icon_url': iconUrl,
      };
}

// ─── Channel model ────────────────────────────────────────────────────────────

class ChannelModel {
  final String id;
  final String name;
  final String description;
  final ChannelType type;
  final String? iconUrl;
  final String? orgId;
  final String? createdBy;

  const ChannelModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.iconUrl,
    this.orgId,
    this.createdBy,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) => ChannelModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        type: ChannelTypeX.fromString(json['type'] as String? ?? 'PUBLIC'),
        iconUrl: json['icon_url'] as String?,
        orgId: json['org_id'] as String?,
        createdBy: json['created_by'] as String?,
      );
}

// ─── Response ─────────────────────────────────────────────────────────────────

class CreateChannelResponse {
  final bool success;
  final String? message;
  final ChannelModel? channel;

  const CreateChannelResponse({
    required this.success,
    this.message,
    this.channel,
  });

  factory CreateChannelResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return CreateChannelResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      channel: data != null ? ChannelModel.fromJson(data as Map<String, dynamic>) : null,
    );
  }
}
