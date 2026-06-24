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
        return _buildSystemOwnerReports();
      case UserRole.businessOwner:
        return _buildBusinessOwnerReports();
      case UserRole.branchManager:
        return _buildBranchManagerReports();
    }
  }

  Widget _buildSystemOwnerReports() {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RevenueLineChart(
          title: "Platform Revenue Trends",
          spots: [
            FlSpot(0, 0),
          ],
        ),
        const SizedBox(height: 24),
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
        ),
      ],
    );
  }

  Widget _buildBusinessOwnerReports() {
    final List<FlSpot> weeklySpots = [];
    if (businessData != null && businessData!.weeklySales.isNotEmpty) {
      for (int i = 0; i < businessData!.weeklySales.length; i++) {
        weeklySpots.add(FlSpot(i.toDouble(), businessData!.weeklySales[i].sales));
      }
    } else {
      // Fallback empty spot if no data
      weeklySpots.add(const FlSpot(0, 0));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevenueLineChart(
          title: "Weekly Sales",
          spots: weeklySpots,
        ),
        const SizedBox(height: 24),
        const AiPerformanceSection(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OrderDistributionPieChart(
                title: "Order Sources",
                sections: [
                  PieChartSectionData(color: AppColor.primary, value: 55, title: 'WhatsApp', radius: 50, showTitle: false),
                  PieChartSectionData(color: AppColor.mini, value: 25, title: 'Web App', radius: 50, showTitle: false),
                  PieChartSectionData(color: const Color(0xFFFF9800), value: 20, title: 'In-Store', radius: 50, showTitle: false),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: PerformanceBarChart(
                title: "Branch Performance",
                labels: ['Queens', 'Brooklyn', 'Manhattan', 'Bronx', 'Staten'],
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1200, color: AppColor.primary, width: 16)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1500, color: AppColor.primary, width: 16)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 800, color: AppColor.primary, width: 16)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 1100, color: AppColor.primary, width: 16)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 600, color: AppColor.primary, width: 16)]),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBranchManagerReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PerformanceBarChart(
          title: "Branch Sales (Weekly)",
          labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 0, color: AppColor.primary, width: 12)]),
          ],
        ),
        const SizedBox(height: 24),
        const AiPerformanceSection(),
      ],
    );
  }
}
