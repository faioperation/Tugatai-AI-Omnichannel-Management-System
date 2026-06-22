class SystemOverviewModel {
  final int activeUsers;
  final List<OverviewActivityModel> recentActivity;
  final List<SectorPerformanceModel> topPerformingSectors;
  final List<BusinessDistributionModel> businessDistribution;
  final double platformRevenue;
  final double monthlyRevenue;
  final int activeSubscriptions;
  final int totalBusinesses;

  SystemOverviewModel({
    required this.activeUsers,
    required this.recentActivity,
    required this.topPerformingSectors,
    required this.businessDistribution,
    required this.platformRevenue,
    required this.monthlyRevenue,
    required this.activeSubscriptions,
    required this.totalBusinesses,
  });

  factory SystemOverviewModel.fromJson(Map<String, dynamic> json) {
    return SystemOverviewModel(
      activeUsers: json['activeUsers'] ?? 0,
      recentActivity: (json['recentActivity'] as List?)
              ?.map((e) => OverviewActivityModel.fromJson(e))
              .toList() ??
          [],
      topPerformingSectors: (json['topPerformingSectors'] as List?)
              ?.map((e) => SectorPerformanceModel.fromJson(e))
              .toList() ??
          [],
      businessDistribution: (json['businessDistribution'] as List?)
              ?.map((e) => BusinessDistributionModel.fromJson(e))
              .toList() ??
          [],
      platformRevenue: (json['platformRevenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      activeSubscriptions: json['activeSubscriptions'] ?? 0,
      totalBusinesses: json['totalBusinesses'] ?? 0,
    );
  }
}

class OverviewActivityModel {
  final String id;
  final String activityName;
  final String activityTitle;
  final String activityType;
  final bool markAsRead;
  final String? createdById;
  final DateTime? createdAt;
  final String? createdByFirstName;
  final String? createdByEmail;

  OverviewActivityModel({
    required this.id,
    required this.activityName,
    required this.activityTitle,
    required this.activityType,
    required this.markAsRead,
    this.createdById,
    this.createdAt,
    this.createdByFirstName,
    this.createdByEmail,
  });

  factory OverviewActivityModel.fromJson(Map<String, dynamic> json) {
    final createdBy = json['createdBy'] as Map<String, dynamic>?;
    return OverviewActivityModel(
      id: json['id'] ?? '',
      activityName: json['activityName'] ?? '',
      activityTitle: json['activityTitle'] ?? '',
      activityType: json['activityType'] ?? '',
      markAsRead: json['markAsRead'] ?? false,
      createdById: json['createdById'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      createdByFirstName: createdBy?['firstName'],
      createdByEmail: createdBy?['email'],
    );
  }
}

class SectorPerformanceModel {
  final String sector;
  final int count;
  final double percentage;

  SectorPerformanceModel({
    required this.sector,
    required this.count,
    required this.percentage,
  });

  factory SectorPerformanceModel.fromJson(Map<String, dynamic> json) {
    return SectorPerformanceModel(
      sector: json['sector'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class BusinessDistributionModel {
  final String category;
  final int count;
  final double percentage;

  BusinessDistributionModel({
    required this.category,
    required this.count,
    required this.percentage,
  });

  factory BusinessDistributionModel.fromJson(Map<String, dynamic> json) {
    return BusinessDistributionModel(
      category: json['category'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}
