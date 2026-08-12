class PermissionModel {
  final String id;
  final String name;
  final String? description;

  PermissionModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class StaffUserModel {
  final String id;
  final String email;
  final String firstName;
  final String? lastName;
  final String? phone;
  final String? status;
  final bool isVerified;
  final List<String> roles;
  final List<PermissionModel> permissions;
  final String? createdAt;

  StaffUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
    this.phone,
    this.status,
    this.isVerified = true,
    this.roles = const [],
    this.permissions = const [],
    this.createdAt,
  });

  factory StaffUserModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedRoles = [];
    if (json['roles'] != null && json['roles'] is List) {
      parsedRoles = (json['roles'] as List).map((e) => e.toString()).toList();
    }

    List<PermissionModel> parsedPermissions = [];
    if (json['permissions'] != null && json['permissions'] is List) {
      parsedPermissions = (json['permissions'] as List)
          .map((p) => PermissionModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return StaffUserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      phone: json['phone'],
      status: json['status'] ?? 'ACTIVE',
      isVerified: json['isVerified'] ?? true,
      roles: parsedRoles,
      permissions: parsedPermissions,
      createdAt: json['createdAt'],
    );
  }
}
