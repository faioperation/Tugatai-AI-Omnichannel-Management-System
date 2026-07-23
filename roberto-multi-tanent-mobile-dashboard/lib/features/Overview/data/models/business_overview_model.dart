import 'package:roberto/features/Overview/data/models/system_overview_model.dart';

class BusinessOverviewModel {
  final int todayOrders;
  final int pendingDeliveries;
  final double todaysSales;
  final double totalSales;
  final ActiveUsersModel activeUsers;
  final List<WeeklySalesModel> weeklySales;
  final List<OverviewActivityModel> recentActivity;
  final List<BranchPerformanceModel> branchPerformance;

  BusinessOverviewModel({
    required this.todayOrders,
    required this.pendingDeliveries,
    required this.todaysSales,
    this.totalSales = 0.0,
    required this.activeUsers,
    required this.weeklySales,
    required this.recentActivity,
    required this.branchPerformance,
  });

  factory BusinessOverviewModel.fromJson(Map<String, dynamic> json) {
    final branches = (json['branchPerformance'] as List?)
            ?.map((e) => BranchPerformanceModel.fromJson(e))
            .toList() ??
        [];
    // Compute totalSales from API field or sum of branchPerformance
    final double apiTotalSales = (json['totalSales'] ?? 0).toDouble();
    final double computedTotalSales = apiTotalSales > 0
        ? apiTotalSales
        : branches.fold(0.0, (sum, b) => sum + b.totalSales);

    return BusinessOverviewModel(
      todayOrders: json['todayOrders'] ?? 0,
      pendingDeliveries: json['pendingDeliveries'] ?? 0,
      todaysSales: (json['todaysSales'] ?? 0).toDouble(),
      totalSales: computedTotalSales,
      activeUsers: ActiveUsersModel.fromJson(json['activeUsers'] ?? {}),
      weeklySales: (json['weeklySales'] as List?)
              ?.map((e) => WeeklySalesModel.fromJson(e))
              .toList() ??
          [],
      recentActivity: (json['recentActivity'] as List?)
              ?.map((e) => OverviewActivityModel.fromJson(e))
              .toList() ??
          [],
      branchPerformance: branches,
    );
  }
}

class BranchPerformanceModel {
  final String branchId;
  final String branchName;
  final int totalOrders;
  final double totalSales;

  BranchPerformanceModel({
    required this.branchId,
    required this.branchName,
    required this.totalOrders,
    required this.totalSales,
  });

  factory BranchPerformanceModel.fromJson(Map<String, dynamic> json) {
    return BranchPerformanceModel(
      branchId: json['branchId'] ?? '',
      branchName: json['branchName'] ?? '',
      totalOrders: json['totalOrders'] ?? 0,
      totalSales: (json['totalSales'] ?? 0).toDouble(),
    );
  }
}

class ActiveUsersModel {
  final int total;
  final int whatsapp;
  final int messenger;
  final int instagram;

  ActiveUsersModel({
    required this.total,
    required this.whatsapp,
    required this.messenger,
    required this.instagram,
  });

  factory ActiveUsersModel.fromJson(Map<String, dynamic> json) {
    return ActiveUsersModel(
      total: json['total'] ?? 0,
      whatsapp: json['whatsapp'] ?? 0,
      messenger: json['messenger'] ?? 0,
      instagram: json['instagram'] ?? 0,
    );
  }
}

class WeeklySalesModel {
  final String week;
  final int orders;
  final double sales;

  WeeklySalesModel({
    required this.week,
    required this.orders,
    required this.sales,
  });

  factory WeeklySalesModel.fromJson(Map<String, dynamic> json) {
    return WeeklySalesModel(
      week: json['week'] ?? '',
      orders: json['orders'] ?? 0,
      sales: (json['sales'] ?? 0).toDouble(),
    );
  }
}
