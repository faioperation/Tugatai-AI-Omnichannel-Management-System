import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/features/businesssubscription/widget/subscription_row.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_headder.dart';

class CustomHistory extends StatefulWidget {
  const CustomHistory({super.key});

  @override
  State<CustomHistory> createState() => _CustomHistoryState();
}

class _CustomHistoryState extends State<CustomHistory> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;
    final bool isMobile = width <= 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Billing History",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "View all past transactions and invoices",
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),

              // EXPORT BUTTON
              InkWell(
                onTap: () {
                  print("Export clicked");
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerTheme.color ?? const Color(0xffEEEEEE),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download, size: 18, color: theme.colorScheme.onSurface),
                      if (!isMobile) ...[
                        const SizedBox(width: 6),
                        Text(
                          "Export",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          isDesktop ? _buildDesktopTable() : _buildMobileList(),
        ],
      ),
    );
  }

  Widget _buildDesktopTable() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              color: isDark ? theme.colorScheme.surface : AppColor.secondary,
              child: const Row(
                children: [
                  Expanded(flex: 2, child: CustomHeadder(label: 'Billing Date')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Plan')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Subscription Pricing')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Expire Date')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Status')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Actions')),
                ],
              ),
            ),
            _buildRows(isMobile: false),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return _buildRows(isMobile: true);
  }

  Widget _buildRows({required bool isMobile}) {
    return Column(
      children: [
        SubscriptionRow(
          date: "Apr 1, 2026",
          plan: "Half Moon",
          price: "\$49/Monthly",
          expireDate: "May 1, 2026",
          status: "Paid",
          isMobile: isMobile,
        ),
        SubscriptionRow(
          date: "Mar 1, 2026",
          plan: "Half Moon",
          price: "\$49/Monthly",
          expireDate: "Apr 1, 2026",
          status: "Unpaid",
          isMobile: isMobile,
        ),
        SubscriptionRow(
          date: "Feb 1, 2026",
          plan: "Half Moon",
          price: "\$49/Monthly",
          expireDate: "Mar 1, 2026",
          status: "Paid",
          isMobile: isMobile,
        ),
        SubscriptionRow(
          date: "Jan 1, 2026",
          plan: "Half Moon",
          price: "\$49/Monthly",
          expireDate: "Feb 1, 2026",
          status: "Unpaid",
          isMobile: isMobile,
        ),
      ],
    );
  }
}
