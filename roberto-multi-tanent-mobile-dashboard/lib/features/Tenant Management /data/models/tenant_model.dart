class TenantResponse {
  final List<TenantBusiness> businesses;
  final int totalTenants;
  final int activeTenants;
  final double mrr;

  TenantResponse({
    required this.businesses,
    required this.totalTenants,
    required this.activeTenants,
    required this.mrr,
  });

  factory TenantResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return TenantResponse(
      businesses: (data['businesses'] as List<dynamic>?)
              ?.map((e) => TenantBusiness.fromJson(e))
              .toList() ??
          [],
      totalTenants: data['totalTenants'] ?? 0,
      activeTenants: data['activeTenants'] ?? 0,
      mrr: (data['mrr'] ?? 0).toDouble(),
    );
  }
}

class TenantBranch {
  final String id;
  final String name;

  TenantBranch({required this.id, required this.name});

  factory TenantBranch.fromJson(Map<String, dynamic> json) {
    return TenantBranch(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Default Branch',
    );
  }
}

class TenantBusiness {
  final String id;
  final String? ownerId;
  final String name;
  final String? email;
  final String? phone;
  final String? industry;
  final String? status;
  final String? planCycle;
  final int? credits;
  final String? businessType;
  final String? createdAt;
  final TenantOwner? owner;
  final List<TenantBranch> branches;

  TenantBusiness({
    required this.id,
    this.ownerId,
    required this.name,
    this.email,
    this.phone,
    this.industry,
    this.status,
    this.planCycle,
    this.credits,
    this.businessType,
    this.createdAt,
    this.owner,
    required this.branches,
  });

  factory TenantBusiness.fromJson(Map<String, dynamic> json) {
    return TenantBusiness(
      id: json['id'] ?? '',
      ownerId: json['ownerId'],
      name: json['name'] ?? 'Unknown',
      email: json['email'],
      phone: json['phone'],
      industry: json['industry'],
      status: json['status'],
      planCycle: json['planCycle'],
      credits: json['credits'],
      businessType: json['businessType'],
      createdAt: json['createdAt'],
      owner: json['owner'] != null ? TenantOwner.fromJson(json['owner']) : null,
      branches: (json['branches'] as List<dynamic>?)
              ?.map((e) => TenantBranch.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TenantOwner {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;

  TenantOwner({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
  });

  factory TenantOwner.fromJson(Map<String, dynamic> json) {
    return TenantOwner(
      id: json['id'] ?? '',
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}
