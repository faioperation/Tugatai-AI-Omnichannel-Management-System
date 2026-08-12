import 'package:roberto/common/user_role.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String? lastName;
  final String? profilePicture;
  final UserRole? primaryRole;
  final String? branchName;
  final String? branchAddress;
  final String? branchId;
  final String? businessType;
  final List<String> permissions;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
    this.profilePicture,
    this.primaryRole,
    this.branchName,
    this.branchAddress,
    this.branchId,
    this.businessType,
    this.permissions = const [],
  });

  bool hasPermission(String permissionName) {
    if (primaryRole == UserRole.systemOwner) return true;
    return permissions.contains(permissionName);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole? parsedRole;

    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      final roleList = json['roles'] as List;
      for (var r in roleList) {
        final roleData = r['role'];
        if (roleData != null && roleData['name'] != null) {
          String roleName = roleData['name'];
          if (roleName == 'SYSTEM_OWNER') {
            parsedRole = UserRole.systemOwner;
            break;
          } else if (roleName == 'SYSTEM_STAFF') {
            parsedRole = UserRole.systemStaff;
            break;
          } else if (roleName == 'BUSINESS_OWNER') {
            parsedRole = UserRole.businessOwner;
            break;
          } else if (roleName == 'BRANCH_MANAGER') {
            parsedRole = UserRole.branchManager;
            break;
          }
        }
      }
    }

    List<String> parsedPermissions = [];
    if (json['permissions'] != null && json['permissions'] is List) {
      for (var p in json['permissions']) {
        if (p is Map && p['name'] != null) {
          parsedPermissions.add(p['name'].toString());
        } else if (p is String) {
          parsedPermissions.add(p.toString());
        }
      }
    }

    final branch = json['branch'] as Map<String, dynamic>?;
    final tenant = branch?['tenant'] as Map<String, dynamic>? ?? json['tenant'] as Map<String, dynamic>? ?? json['business'] as Map<String, dynamic>?;
    final parsedBusinessType = json['businessType'] ?? 
                               branch?['businessType'] ?? 
                               tenant?['businessType'] ??
                               json['business']?['businessType'];

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      profilePicture: json['profilePicture'],
      primaryRole: parsedRole,
      branchName: json['branch']?['name'],
      branchAddress: json['branch']?['address'],
      branchId: json['branch']?['id'],
      businessType: parsedBusinessType?.toString(),
      permissions: parsedPermissions,
    );
  }
}
