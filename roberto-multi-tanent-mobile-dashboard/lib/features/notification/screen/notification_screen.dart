import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/notification/widget/custom_notification.dart';
import 'package:roberto/features/notification/bloc/notification_bloc.dart';
import 'package:roberto/features/notification/bloc/notification_event.dart';
import 'package:roberto/features/notification/bloc/notification_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotificationsRequested());
  }

  void _markAllAsRead() {
    context.read<NotificationBloc>().add(MarkAllNotificationsAsRead());
  }

  String _getSvgPathForType(String? type, String? title) {
    // Return standard svgs based on type or title keywords
    final t = (type ?? title ?? '').toLowerCase();
    if (t.contains('booking')) return 'assets/bn.svg';
    if (t.contains('message') || t.contains('whatsapp')) return 'assets/mn.svg';
    if (t.contains('system') || t.contains('update')) return 'assets/sn.svg';
    return 'assets/on.svg'; // default (e.g. order)
  }

  String _formatTime(String createdAt) {
    if (createdAt.isEmpty) return 'Just now';
    try {
      final date = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return '${diff.inDays} days ago';
      if (diff.inHours > 0) return '${diff.inHours} hours ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
      return 'Just now';
    } catch (e) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE),
          width: 1,
        ),
      ),
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          final notifications = state.notifications;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${notifications.length} notifications',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 15,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  if (notifications.isNotEmpty)
                    TextButton.icon(
                      onPressed: _markAllAsRead,
                      icon: Icon(Icons.done_all, size: isMobile ? 16 : 18, color: AppColor.primary),
                      label: Text(
                        'Mark all as read',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (state is NotificationLoading && notifications.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (state is NotificationError && notifications.isEmpty)
                Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (notifications.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No notifications found',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ),
                )
              else
                ...notifications.map((n) {
                  return CustomNotification(
                    svgPath: _getSvgPathForType(n.type, n.title),
                    title: n.title,
                    subtitle: n.message,
                    time: _formatTime(n.createdAt),
                    showDot: !n.isRead,
                    onTap: n.isRead
                        ? null
                        : () {
                            context.read<NotificationBloc>().add(MarkNotificationAsRead(notificationId: n.id));
                          },
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}