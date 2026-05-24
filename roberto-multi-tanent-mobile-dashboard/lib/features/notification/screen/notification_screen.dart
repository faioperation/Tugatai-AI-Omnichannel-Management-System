import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/notification/widget/custom_notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      "svgPath": "assets/on.svg",
      "title": "New Order Received",
      "subtitle": "Order #TGT-12345678 from Sarah Johnson has been placed",
      "time": "2 minutes ago",
      "showDot": true,
    },
    {
      "svgPath": "assets/bn.svg",
      "title": "Booking Confirmed",
      "subtitle": "Michael Chen's booking for April 15, 2026 at 10:00 AM",
      "time": "15 minutes ago",
      "showDot": true,
    },
    {
      "svgPath": "assets/mn.svg",
      "title": "New Message on WhatsApp",
      "subtitle": "Emma Wilson: Can you provide a quote for my shipment?",
      "time": "1 hour ago",
      "showDot": true,
    },
    {
      "svgPath": "assets/on.svg",
      "title": "Order Status Updated",
      "subtitle": "Order #TGT-23456789 status changed to In Transit",
      "time": "2 hours ago",
      "showDot": false,
    },
    {
      "svgPath": "assets/bn.svg",
      "title": "Booking Request",
      "subtitle": "New booking request from James Rodriguez",
      "time": "3 hours ago",
      "showDot": false,
    },
    {
      "svgPath": "assets/sn.svg",
      "title": "System Update",
      "subtitle": "Pricing engine has been updated with new rates",
      "time": "5 hours ago",
      "showDot": false,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['showDot'] = false;
      }
    });
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
          color:
              Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE),
          width: 1,
        ),
      ),
      child: Column(
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
                    '${_notifications.length} notifications',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
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
          ..._notifications.map((n) => CustomNotification(
                svgPath: n['svgPath'],
                title: n['title'],
                subtitle: n['subtitle'],
                time: n['time'],
                showDot: n['showDot'],
              )),
        ],
      ),
    );
  }
}