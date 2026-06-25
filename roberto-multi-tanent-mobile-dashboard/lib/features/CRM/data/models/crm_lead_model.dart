class CrmLeadModel {
  final String? id;
  final String? businessId;
  final String? createdById;
  final String? branchId;
  final String? name;
  final String? email;
  final String? phone;
  final String? source;
  final String? address;
  final String? note;
  final String? status;
  final Map<String, dynamic>? metadata;
  final String? createdAt;
  final String? updatedAt;

  CrmLeadModel({
    this.id,
    this.businessId,
    this.createdById,
    this.branchId,
    this.name,
    this.email,
    this.phone,
    this.source,
    this.address,
    this.note,
    this.status,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory CrmLeadModel.fromJson(Map<String, dynamic> json) {
    return CrmLeadModel(
      id: json['id'] as String?,
      businessId: json['businessId'] as String?,
      createdById: json['createdById'] as String?,
      branchId: json['branchId'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      source: json['source'] as String?,
      address: json['address'] as String?,
      note: json['note'] as String?,
      status: json['status'] as String?,
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'createdById': createdById,
      'branchId': branchId,
      'name': name,
      'email': email,
      'phone': phone,
      'source': source,
      'address': address,
      'note': note,
      'status': status,
      'metadata': metadata,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CrmLeadModel copyWith({
    String? id,
    String? businessId,
    String? createdById,
    String? branchId,
    String? name,
    String? email,
    String? phone,
    String? source,
    String? address,
    String? note,
    String? status,
    Map<String, dynamic>? metadata,
    String? createdAt,
    String? updatedAt,
  }) {
    return CrmLeadModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      createdById: createdById ?? this.createdById,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      source: source ?? this.source,
      address: address ?? this.address,
      note: note ?? this.note,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
