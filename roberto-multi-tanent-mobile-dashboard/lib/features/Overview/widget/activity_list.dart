import 'package:flutter/material.dart';
import 'package:roberto/features/Overview/data/models/system_overview_model.dart';
import 'package:roberto/features/Overview/data/models/business_overview_model.dart';
import 'package:intl/intl.dart';

class ActivityList extends StatelessWidget {
  final SystemOverviewModel? overviewData;
  final BusinessOverviewModel? businessData;

  const ActivityList({super.key, this.overviewData, this.businessData});

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(Icons.trending_up, color: Theme.of(context).iconTheme.color, size: 20),
              const SizedBox(width: 8),
              Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (overviewData != null && overviewData!.recentActivity.isNotEmpty)
            ...overviewData!.recentActivity.map((activity) {
              final timeString = activity.createdAt != null 
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(activity.createdAt!) 
                  : 'Just now';
              return _buildActivityItem(
                context,
                activity.activityTitle,
                timeString,
                !activity.markAsRead,
              );
            }).toList()
          else if (businessData != null && businessData!.recentActivity.isNotEmpty)
            ...businessData!.recentActivity.map((activity) {
              final timeString = activity.createdAt != null 
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(activity.createdAt!) 
                  : 'Just now';
              return _buildActivityItem(
                context,
                activity.activityTitle,
                timeString,
                !activity.markAsRead,
              );
            }).toList()
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No recent activity"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String activity, String time, bool isNew) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
