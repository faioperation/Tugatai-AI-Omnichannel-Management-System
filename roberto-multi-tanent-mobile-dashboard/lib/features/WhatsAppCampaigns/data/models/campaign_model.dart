class CampaignModel {
  final String id;
  final String title;
  final String status;
  final String message;
  final String? branchId;
  final List<String>? selectedPeople;
  final DateTime? scheduledTime;
  final DateTime? endDate;
  final bool? isExpire;
  final DateTime createdAt;
  final DateTime updatedAt;

  CampaignModel({
    required this.id,
    required this.title,
    required this.status,
    required this.message,
    this.branchId,
    this.selectedPeople,
    this.scheduledTime,
    this.endDate,
    this.isExpire,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 'PENDING',
      message: json['message'] ?? '',
      branchId: json['branchId'],
      selectedPeople: json['selectedPeople'] != null ? List<String>.from(json['selectedPeople']) : null,
      scheduledTime: json['scheduledTime'] != null ? DateTime.tryParse(json['scheduledTime']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      isExpire: json['isExpire'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'message': message,
      'branchId': branchId,
      'selectedPeople': selectedPeople,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isExpire': isExpire,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
