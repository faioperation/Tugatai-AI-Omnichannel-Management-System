import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/user_role.dart';
import 'package:roberto/features/Overview/widget/analytics_charts.dart';
import 'package:roberto/features/Overview/widget/ai_analytics.dart';
import 'package:roberto/features/Overview/data/models/system_overview_model.dart';
import 'package:roberto/features/Overview/data/models/business_overview_model.dart';

class RoleReports extends StatelessWidget {
  final UserRole role;
  final SystemOverviewModel? overviewData;
  final BusinessOverviewModel? businessData;

  const RoleReports({super.key, required this.role, this.overviewData, this.businessData});

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.systemOwner:
        return _buildSystemOwnerReports(context);
      case UserRole.businessOwner:
        return _buildBusinessOwnerReports(context);
      case UserRole.branchManager:
        return _buildBranchManagerReports(context);
    }
  }

  Widget _buildSystemOwnerReports(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    // Build dynamic sections for Business Distribution
    final List<PieChartSectionData> businessSections = overviewData?.businessDistribution.map((e) {
      // Assign random or pre-defined colors based on category index, for simplicity we map directly or use a generated color list
      return PieChartSectionData(
        color: AppColor.primary.withOpacity((e.percentage / 100).clamp(0.2, 1.0)),
        value: e.percentage,
        title: e.category,
        radius: 50,
        showTitle: false,
      );
    }).toList() ?? [];

    if (businessSections.isEmpty) {
      businessSections.add(PieChartSectionData(color: Colors.grey, value: 100, title: 'No Data', radius: 50, showTitle: false));
    }

    // Build dynamic sections for Top Performing Sectors
    final List<String> sectorLabels = overviewData?.topPerformingSectors.map((e) => e.sector).toList() ?? [];
    final List<BarChartGroupData> sectorBars = overviewData?.topPerformingSectors.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [BarChartRodData(toY: entry.value.count.toDouble(), color: AppColor.primary, width: 16)],
      );
    }).toList() ?? [];

    // Build dynamic spots for Platform Revenue Trends
    final List<FlSpot> revenueSpots = [];
    if (overviewData != null && overviewData!.platformRevenue.isNotEmpty) {
      for (int i = 0; i < overviewData!.platformRevenue.length; i++) {
        revenueSpots.add(FlSpot(i.toDouble(), overviewData!.platformRevenue[i].revenue));
      }
    } else {
      revenueSpots.add(const FlSpot(0, 0));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevenueLineChart(
          title: "Platform Revenue Trends",
          spots: revenueSpots,
        ),
        const SizedBox(height: 24),
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: OrderDistributionPieChart(
                  title: "Business Distribution",
                  sections: businessSections,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PerformanceBarChart(
                  title: "Top Performing Sectors",
                  labels: sectorLabels.isNotEmpty ? sectorLabels : ['No Data'],
                  barGroups: sectorBars.isNotEmpty ? sectorBars : [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 16)])
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              OrderDistributionPieChart(
                title: "Business Distribution",
                sections: businessSections,
              ),
              const SizedBox(height: 24),
              PerformanceBarChart(
                title: "Top Performing Sectors",
                labels: sectorLabels.isNotEmpty ? sectorLabels : ['No Data'],
                barGroups: sectorBars.isNotEmpty ? sectorBars : [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 16)])
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBusinessOwnerReports(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    final List<FlSpot> weeklySpots = [];
    final List<String> weeklyLabels = [];
    if (businessData != null && businessData!.weeklySales.isNotEmpty) {
      for (int i = 0; i < businessData!.weeklySales.length; i++) {
        weeklySpots.add(FlSpot(i.toDouble(), businessData!.weeklySales[i].sales));
        weeklyLabels.add(businessData!.weeklySales[i].week);
      }
    } else {
      // Fallback empty spot if no data
      weeklySpots.add(const FlSpot(0, 0));
      weeklyLabels.add("No Data");
    }

    // Dynamic Order Sources from activeUsers
    final List<PieChartSectionData> orderSources = [];
    if (businessData != null) {
      final total = businessData!.activeUsers.total;
      if (total > 0) {
        if (businessData!.activeUsers.whatsapp > 0) {
          orderSources.add(PieChartSectionData(color: AppColor.primary, value: businessData!.activeUsers.whatsapp.toDouble(), title: 'WhatsApp', radius: 50, showTitle: false));
        }
        if (businessData!.activeUsers.messenger > 0) {
          orderSources.add(PieChartSectionData(color: AppColor.mini, value: businessData!.activeUsers.messenger.toDouble(), title: 'Messenger', radius: 50, showTitle: false));
        }
        if (businessData!.activeUsers.instagram > 0) {
          orderSources.add(PieChartSectionData(color: const Color(0xFFFF9800), value: businessData!.activeUsers.instagram.toDouble(), title: 'Instagram', radius: 50, showTitle: false));
        }
      }
    }
    if (orderSources.isEmpty) {
      orderSources.add(PieChartSectionData(color: Colors.grey, value: 100, title: 'No Data', radius: 50, showTitle: false));
    }

    // Dynamic Branch Performance
    final List<String> branchLabels = [];
    final List<BarChartGroupData> branchBars = [];
    if (businessData != null && businessData!.branchPerformance.isNotEmpty) {
      double totalAllBranches = 0;
      for (var branch in businessData!.branchPerformance) {
        totalAllBranches += branch.totalSales;
      }
      
      for (int i = 0; i < businessData!.branchPerformance.length; i++) {
        final branch = businessData!.branchPerformance[i];
        double percentage = totalAllBranches > 0 ? (branch.totalSales / totalAllBranches) * 100 : 0;
        branchLabels.add(branch.branchName);
        branchBars.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: percentage, color: AppColor.primary, width: 16)]));
      }
    } else {
      branchLabels.add('No Data');
      branchBars.add(BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 16)]));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevenueLineChart(
          title: "Weekly Sales",
          spots: weeklySpots,
          xLabels: weeklyLabels,
        ),
        const SizedBox(height: 24),
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: OrderDistributionPieChart(
                  title: "Order Sources",
                  sections: orderSources,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PerformanceBarChart(
                  title: "Branch Performance",
                  labels: branchLabels,
                  barGroups: branchBars,
                  isPercentage: true,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              OrderDistributionPieChart(
                title: "Order Sources",
                sections: orderSources,
              ),
              const SizedBox(height: 24),
              PerformanceBarChart(
                title: "Branch Performance",
                labels: branchLabels,
                barGroups: branchBars,
                isPercentage: true,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBranchManagerReports(BuildContext context) {
    final List<FlSpot> weeklySpots = [];
    final List<String> weeklyLabels = [];
    if (businessData != null && businessData!.weeklySales.isNotEmpty) {
      for (int i = 0; i < businessData!.weeklySales.length; i++) {
        weeklySpots.add(FlSpot(i.toDouble(), businessData!.weeklySales[i].sales));
        weeklyLabels.add(businessData!.weeklySales[i].week);
      }
    } else {
      weeklySpots.add(const FlSpot(0, 0));
      weeklyLabels.add("No Data");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevenueLineChart(
          title: "Branch Sales (Weekly)",
          spots: weeklySpots,
          xLabels: weeklyLabels,
        ),
      ],
    );
  }
}
