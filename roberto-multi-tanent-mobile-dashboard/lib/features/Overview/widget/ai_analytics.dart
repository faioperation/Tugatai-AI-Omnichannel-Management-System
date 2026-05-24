import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';

class AiAnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<FlSpot> sparklineSpots;
  final Color color;

  const AiAnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.sparklineSpots,
    this.color = AppColor.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 40,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: sparklineSpots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiPerformanceSection extends StatelessWidget {
  const AiPerformanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "AI Agent Performance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Last 7 Days",
              style: TextStyle(
                fontSize: 14,
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            return isMobile 
              ? Column(
                  children: _buildCards().map((card) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: card,
                  )).toList(),
                )
              : Row(
                  children: _buildCards().map((card) => Expanded(child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: card,
                  ))).toList(),
                );
          },
        ),
      ],
    );
  }

  List<Widget> _buildCards() {
    return [
      const AiAnalyticsCard(
        title: "Active Chats",
        value: "142",
        subtitle: "+12%",
        icon: Icons.chat_bubble_outline_rounded,
        color: Color(0xFF6366F1), // Indigo
        sparklineSpots: [
          FlSpot(0, 80),
          FlSpot(1, 95),
          FlSpot(2, 110),
          FlSpot(3, 105),
          FlSpot(4, 120),
          FlSpot(5, 135),
          FlSpot(6, 142),
        ],
      ),
      const AiAnalyticsCard(
        title: "Success",
        value: "84%",
        subtitle: "+5%",
        icon: Icons.auto_awesome_rounded,
        color: Color(0xFF10B981), // Emerald
        sparklineSpots: [
          FlSpot(0, 70),
          FlSpot(1, 75),
          FlSpot(2, 72),
          FlSpot(3, 80),
          FlSpot(4, 78),
          FlSpot(5, 82),
          FlSpot(6, 84),
        ],
      ),
      const AiAnalyticsCard(
        title: "CSAT",
        value: "4.8",
        subtitle: "Stable",
        icon: Icons.stars_rounded,
        color: Color(0xFFF59E0B), // Amber
        sparklineSpots: [
          FlSpot(0, 4.5),
          FlSpot(1, 4.6),
          FlSpot(2, 4.7),
          FlSpot(3, 4.6),
          FlSpot(4, 4.8),
          FlSpot(5, 4.8),
          FlSpot(6, 4.8),
        ],
      ),
    ];
  }
}
