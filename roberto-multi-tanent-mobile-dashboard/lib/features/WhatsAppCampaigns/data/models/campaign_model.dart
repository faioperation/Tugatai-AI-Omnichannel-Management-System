class CampaignModel {
  final String id;
  final String title;
  final String status;
  final String? description;
  final String? inboxId;
  final String? audience;
  final DateTime createdAt;
  final DateTime updatedAt;

  CampaignModel({
    required this.id,
    required this.title,
    required this.status,
    this.description,
    this.inboxId,
    this.audience,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 'PENDING',
      description: json['description'] ?? json['message'] ?? '',
      inboxId: json['inboxId'],
      audience: json['audience'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'description': description,
      'inboxId': inboxId,
      'audience': audience,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
