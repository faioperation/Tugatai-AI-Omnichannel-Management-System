import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/common/user_role.dart';
import 'package:roberto/features/Overview/bloc/overview_bloc.dart';
import 'package:roberto/features/Overview/bloc/overview_event.dart';
import 'package:roberto/features/Overview/bloc/overview_state.dart';
import 'package:roberto/features/Overview/data/models/system_overview_model.dart';
import 'package:roberto/features/Overview/data/models/business_overview_model.dart';
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
  void initState() {
    super.initState();
    if (widget.role == UserRole.systemOwner) {
      context.read<OverviewBloc>().add(FetchSystemOverviewRequested());
    } else if (widget.role == UserRole.businessOwner) {
      context.read<OverviewBloc>().add(FetchBusinessOverviewRequested());
    }
  }

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
  
          // STAT CARDS & ANALYTICS & QUICK STATS
          BlocBuilder<OverviewBloc, OverviewState>(
            builder: (context, state) {
              if (isSystemOwner || widget.role == UserRole.businessOwner) {
                if (state is OverviewLoading) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ));
                } else if (state is OverviewError) {
                  return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
                } else if (state is SystemOverviewLoaded) {
                  final data = state.overviewData;
                  return _buildDashboardContent(context, isDesktop, systemData: data);
                } else if (state is BusinessOverviewLoaded) {
                  final data = state.businessData;
                  return _buildDashboardContent(context, isDesktop, businessData: data);
                }
                return const SizedBox.shrink(); // Initial state
              } else {
                // For other roles, use static/existing content for now
                return _buildDashboardContent(context, isDesktop);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, bool isDesktop, {SystemOverviewModel? systemData, BusinessOverviewModel? businessData}) {
    return Column(
      children: [
        isDesktop 
          ? Row(
              children: _buildStatCards(context, systemData: systemData, businessData: businessData),
            )
          : Column(
              children: _buildStatCards(context, systemData: systemData, businessData: businessData).map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: card,
              )).toList(),
            ),
            
        const SizedBox(height: 32),

        // ANALYTICS & REPORTS
        RoleReports(role: widget.role, overviewData: systemData, businessData: businessData),

        const SizedBox(height: 32),

        // RECENT ACTIVITY & QUICK STATS
        isDesktop 
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ActivityList(overviewData: systemData, businessData: businessData),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: QuickStats(overviewData: systemData, businessData: businessData),
                ),
              ],
            )
          : Column(
              children: [
                ActivityList(overviewData: systemData, businessData: businessData),
                const SizedBox(height: 24),
                QuickStats(overviewData: systemData, businessData: businessData),
              ],
            ),
      ],
    );
  }

  List<Widget> _buildStatCards(BuildContext context, {SystemOverviewModel? systemData, BusinessOverviewModel? businessData}) {
    final isSystemOwner = widget.role == UserRole.systemOwner;
    final isBranchManager = widget.role == UserRole.branchManager;

    if (isSystemOwner) {
      return [
        Expanded(
          child: StatCard(
            title: "Total Businesses",
            value: systemData != null ? "${systemData.totalBusinesses}" : "0",
            trend: "", // Removed static trend
            icon: Icons.business,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Active Subscriptions",
            value: systemData != null ? "${systemData.activeSubscriptions}" : "0",
            trend: "", // Removed static trend
            icon: Icons.subscriptions_outlined,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Monthly Revenue",
            value: systemData != null ? "\$${systemData.monthlyRevenue.toStringAsFixed(2)}" : "\$0.00",
            trend: "", // Removed static trend
            icon: Icons.payments_outlined,
          ),
        ),
      ];
    } else if (isBranchManager) {
      return [
        const Expanded(
          child: StatCard(
            title: "Today's Orders",
            value: "0",
            trend: "",
            icon: Icons.shopping_bag_outlined,
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: StatCard(
            title: "Pending Deliveries",
            value: "0",
            trend: "",
            icon: Icons.delivery_dining_outlined,
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: StatCard(
            title: "Today's Sales",
            value: "\$0.00",
            trend: "",
            icon: Icons.attach_money,
          ),
        ),
      ];
    } else {
      // Business Owner
      return [
        Expanded(
          child: StatCard(
            title: "Today's Orders",
            value: businessData != null ? "${businessData.todayOrders}" : "0",
            trend: "",
            icon: Icons.shopping_cart_outlined,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Pending Deliveries",
            value: businessData != null ? "${businessData.pendingDeliveries}" : "0",
            trend: "",
            icon: Icons.delivery_dining_outlined,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Today's Sales",
            value: businessData != null ? "\$${businessData.todaysSales.toStringAsFixed(2)}" : "\$0.00",
            trend: "",
            icon: Icons.attach_money,
          ),
        ),
      ];
    }
  }
}

