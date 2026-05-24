import 'package:flutter/material.dart';
import 'package:roberto/common/user_role.dart';
import 'package:roberto/features/Overview/widget/activity_list.dart';
import 'package:roberto/features/Overview/widget/quick_stats.dart';
import 'package:roberto/features/Overview/widget/stat_card.dart';
import 'package:roberto/features/Overview/widget/role_reports.dart';

class OverviewScreen extends StatefulWidget {
  final UserRole role;

  const OverviewScreen({
    super.key,
    this.role = UserRole.businessOwner,
  });

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    final isSystemOwner = widget.role == UserRole.systemOwner;

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSystemOwner ? "System Overview" : "Dashboard Overview",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSystemOwner 
              ? "Welcome, Administrator. Here is the platform's global status."
              : "Welcome back! Here's what's happening in your business today.",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 32),
  
          // STAT CARDS
          isDesktop 
            ? Row(
                children: _buildStatCards(context),
              )
            : Column(
                children: _buildStatCards(context).map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: card,
                )).toList(),
              ),
              
          const SizedBox(height: 32),
  
          // ANALYTICS & REPORTS
          RoleReports(role: widget.role),
  
          const SizedBox(height: 32),
  
          // RECENT ACTIVITY & QUICK STATS
          isDesktop 
            ? const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ActivityList(),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: QuickStats(),
                  ),
                ],
              )
            : Column(
                children: [
                  const ActivityList(),
                  const SizedBox(height: 24),
                  const QuickStats(),
                ],
              ),
        ],
      ),
    );
  }

  List<Widget> _buildStatCards(BuildContext context) {
    final isSystemOwner = widget.role == UserRole.systemOwner;
    final isBranchManager = widget.role == UserRole.branchManager;

    if (isSystemOwner) {
      return [
        const Expanded(
          child: StatCard(
            title: "Total Businesses",
            value: "1,248",
            trend: "+5.2%",
            icon: Icons.business,
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: StatCard(
            title: "Active Subscriptions",
            value: "1,120",
            trend: "+3.8%",
            icon: Icons.subscriptions_outlined,
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: StatCard(
            title: "Monthly Revenue",
            value: "\$124,560",
            trend: "+12.1%",
            icon: Icons.payments_outlined,
          ),
        ),
      ];
    } else if (isBranchManager) {
      return [
        const Expanded(
          child: StatCard(
            title: "Today's Orders",
            value: "42",
            trend: "+15%",
            icon: Icons.shopping_bag_outlined,
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: StatCard(
            title: "Pending Deliveries",
            value: "12",
            trend: "",
            icon: Icons.delivery_dining_outlined,
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: StatCard(
            title: "Today's Sales",
            value: "\$5,420",
            trend: "+8.5%",
            icon: Icons.attach_money,
          ),
        ),
      ];
    } else {
      // Business Owner
      return [
        const Expanded(
          child: StatCard(
            title: "Total Orders",
            value: "856",
            trend: "+8.2%",
            icon: Icons.shopping_cart_outlined,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Total Messages",
            value: "1,234",
            trend: "+12.5%",
            icon: Icons.chat_bubble_outline,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: StatCard(
            title: "Total Revenue",
            value: "\$45,678",
            trend: "+18.7%",
            icon: Icons.attach_money,
          ),
        ),
      ];
    }
  }
}

