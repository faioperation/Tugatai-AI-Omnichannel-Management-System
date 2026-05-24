import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/user_role.dart';
import 'package:roberto/features/Overview/widget/analytics_charts.dart';
import 'package:roberto/features/Overview/widget/ai_analytics.dart';

class RoleReports extends StatelessWidget {
  final UserRole role;

  const RoleReports({super.key, required this.role});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RevenueLineChart(
          title: "Platform Revenue Trends",
          spots: [
            FlSpot(0, 5000),
            FlSpot(2, 7000),
            FlSpot(4, 12000),
            FlSpot(6, 15000),
            FlSpot(8, 18000),
            FlSpot(10, 25000),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OrderDistributionPieChart(
                title: "Business Distribution",
                sections: [
                  PieChartSectionData(color: AppColor.mini, value: 40, title: 'Retail', radius: 50, showTitle: false),
                  PieChartSectionData(color: AppColor.primary, value: 30, title: 'F&B', radius: 50, showTitle: false),
                  PieChartSectionData(color: const Color(0xFFFF9800), value: 20, title: 'Services', radius: 50, showTitle: false),
                  PieChartSectionData(color: Colors.grey, value: 10, title: 'Other', radius: 50, showTitle: false),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: PerformanceBarChart(
                title: "Top Performing Sectors",
                labels: ['Retail', 'F&B', 'IT', 'Agri', 'Med'],
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1500, color: AppColor.primary, width: 16)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1800, color: AppColor.primary, width: 16)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1200, color: AppColor.primary, width: 16)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 900, color: AppColor.primary, width: 16)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 1100, color: AppColor.primary, width: 16)]),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessOwnerReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RevenueLineChart(
          title: "Business Growth (Last 12 Months)",
          spots: [
            FlSpot(0, 2000),
            FlSpot(2, 3500),
            FlSpot(4, 3000),
            FlSpot(6, 4500),
            FlSpot(8, 6000),
            FlSpot(10, 8500),
          ],
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
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 800, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1000, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 900, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 1200, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 1500, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 1800, color: AppColor.primary, width: 12)]),
            BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 1600, color: AppColor.primary, width: 12)]),
          ],
        ),
        const SizedBox(height: 24),
        const AiPerformanceSection(),
      ],
    );
  }
}
