import 'package:flutter/material.dart';
import 'package:roberto/features/Overview/data/models/system_overview_model.dart';

class QuickStats extends StatelessWidget {
  final SystemOverviewModel? overviewData;

  const QuickStats({super.key, this.overviewData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Text(
                "Quick Stats",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
          const SizedBox(height: 24),
          // Hiding static progress bars for System Owner if dynamic data is passed, or show them if not
          if (overviewData == null) ...[
            _buildStatProgress(context, "Response Rate", 0.94, theme.colorScheme.primary, "94%"),
            const SizedBox(height: 20),
            _buildStatProgress(context, "Order Fulfillment", 0.87, theme.colorScheme.secondary, "87%"),
            const SizedBox(height: 20),
            _buildStatProgress(context, "Customer Satisfaction", 0.92, theme.colorScheme.secondary, "92%"),
            const SizedBox(height: 40),
          ] else ...[
             const SizedBox(height: 10),
             Text("System activity and overall usage.", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
             const SizedBox(height: 40),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Active Users",
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
              ),
              Text(
                overviewData != null ? "${overviewData!.activeUsers}" : "248",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatProgress(BuildContext context, String label, double value, Color color, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
