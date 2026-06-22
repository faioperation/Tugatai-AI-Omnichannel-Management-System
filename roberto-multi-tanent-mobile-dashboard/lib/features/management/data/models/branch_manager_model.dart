class BranchManagerModel {
  final String id;
  final String name;
  final String email;
  final String status;
  final String createdById;
  final String businessId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BranchManagerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.createdById,
    required this.businessId,
    this.createdAt,
    this.updatedAt,
  });

  factory BranchManagerModel.fromJson(Map<String, dynamic> json) {
    return BranchManagerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'INACTIVE',
      createdById: json['createdById'] ?? '',
      businessId: json['businessId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
      'createdById': createdById,
      'businessId': businessId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
