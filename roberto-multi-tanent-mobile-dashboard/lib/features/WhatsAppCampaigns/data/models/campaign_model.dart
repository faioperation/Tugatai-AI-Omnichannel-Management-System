class CampaignModel {
  final String id;
  final String name;
  final String branchId;
  final String businessId;
  final String message;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Branch? branch;

  CampaignModel({
    required this.id,
    required this.name,
    required this.branchId,
    required this.businessId,
    required this.message,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.branch,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      branchId: json['branchId'] ?? '',
      businessId: json['businessId'] ?? '',
      message: json['message'] ?? '',
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'branchId': branchId,
      'businessId': businessId,
      'message': message,
      'endDate': endDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (branch != null) 'branch': branch!.toJson(),
    };
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}

class Branch {
  final String id;
  final String name;

  Branch({
    required this.id,
    required this.name,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
