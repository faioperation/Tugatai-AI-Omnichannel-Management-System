import 'package:roberto/common/user_role.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String? lastName;
  final String? profilePicture;
  final UserRole? primaryRole;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
    this.profilePicture,
    this.primaryRole,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole? parsedRole;

    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      final roleList = json['roles'] as List;
      final roleData = roleList.first['role'];
      if (roleData != null && roleData['name'] != null) {
        String roleName = roleData['name'];
        if (roleName == 'SYSTEM_OWNER') {
          parsedRole = UserRole.systemOwner;
        } else if (roleName == 'BUSINESS_OWNER') {
          parsedRole = UserRole.businessOwner;
        } else if (roleName == 'BRANCH_MANAGER') {
          parsedRole = UserRole.branchManager;
        }
      }
    }

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      profilePicture: json['profilePicture'],
      primaryRole: parsedRole,
    );
  }
}
