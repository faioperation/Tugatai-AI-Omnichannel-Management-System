import 'package:roberto/features/Overview/data/models/system_overview_model.dart';

class BusinessOverviewModel {
  final int todayOrders;
  final int pendingDeliveries;
  final double todaysSales;
  final ActiveUsersModel activeUsers;
  final List<WeeklySalesModel> weeklySales;
  final List<OverviewActivityModel> recentActivity;

  BusinessOverviewModel({
    required this.todayOrders,
    required this.pendingDeliveries,
    required this.todaysSales,
    required this.activeUsers,
    required this.weeklySales,
    required this.recentActivity,
  });

  factory BusinessOverviewModel.fromJson(Map<String, dynamic> json) {
    return BusinessOverviewModel(
      todayOrders: json['todayOrders'] ?? 0,
      pendingDeliveries: json['pendingDeliveries'] ?? 0,
      todaysSales: (json['todaysSales'] ?? 0).toDouble(),
      activeUsers: ActiveUsersModel.fromJson(json['activeUsers'] ?? {}),
      weeklySales: (json['weeklySales'] as List?)
              ?.map((e) => WeeklySalesModel.fromJson(e))
              .toList() ??
          [],
      recentActivity: (json['recentActivity'] as List?)
              ?.map((e) => OverviewActivityModel.fromJson(e))
              .toList() ??
          [],
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
