class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String? lastName;
  final String? status;
  final bool isVerified;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
    this.status,
    required this.isVerified,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      status: json['status'],
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'],
    );
  }
}
