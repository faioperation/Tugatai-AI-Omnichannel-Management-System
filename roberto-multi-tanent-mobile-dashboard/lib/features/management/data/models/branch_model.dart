class BranchModel {
  final String id;
  final String businessId;
  final String managerId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? createdAt;
  final String? updatedAt;
  final BranchManagerInfo? manager;

  BranchModel({
    required this.id,
    required this.businessId,
    required this.managerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.createdAt,
    this.updatedAt,
    this.manager,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? '',
      businessId: json['businessId'] ?? '',
      managerId: json['managerId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      manager: json['manager'] != null ? BranchManagerInfo.fromJson(json['manager']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'managerId': managerId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'manager': manager?.toJson(),
    };
  }
}

class BranchManagerInfo {
  final String id;
  final String email;
  final String name;

  BranchManagerInfo({
    required this.id,
    required this.email,
    required this.name,
  });

  factory BranchManagerInfo.fromJson(Map<String, dynamic> json) {
    return BranchManagerInfo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
