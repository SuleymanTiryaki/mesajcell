class OrgModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String? domain;

  const OrgModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.domain,
  });

  factory OrgModel.fromJson(Map<String, dynamic> json) => OrgModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        logoUrl: json['logo_url']?.toString(),
        domain: json['domain']?.toString(),
      );
}
