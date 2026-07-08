class DemoBookingModel {
  final String id;
  final String? name;
  final String? email;
  final String? subject;
  final String? description;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DemoBookingModel({
    required this.id,
    this.name,
    this.email,
    this.subject,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory DemoBookingModel.fromJson(Map<String, dynamic> json) {
    return DemoBookingModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      subject: json['subject'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  DemoBookingModel copyWith({
    String? id,
    String? name,
    String? email,
    String? subject,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DemoBookingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DemoBookingPaginatedResponse {
  final List<DemoBookingModel> bookings;
  final int totalPages;
  final int currentPage;

  DemoBookingPaginatedResponse({
    required this.bookings,
    required this.totalPages,
    required this.currentPage,
  });
}
