import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/TenantManagement/widget/custom_stat_card.dart';
import 'package:roberto/features/TenantManagement/widget/custom_addtenant.dart';
import 'package:roberto/features/TenantManagement/widget/custom_headder.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/TenantManagement/bloc/tenant_bloc.dart';
import 'package:roberto/features/TenantManagement/bloc/tenant_event.dart';
import 'package:roberto/features/TenantManagement/bloc/tenant_state.dart';
import 'package:roberto/features/TenantManagement/data/models/tenant_model.dart';
import '../widget/custom_builditem.dart';

class TenantScreen extends StatefulWidget {
  final Function(String businessId)? onNavigateToAiAgent;

  const TenantScreen({super.key, this.onNavigateToAiAgent});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TenantBloc>().add(const FetchTenantsRequested());
  }

  void _onSearch(String val) {
    context.read<TenantBloc>().add(FetchTenantsRequested(searchParam: val));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        width < 600
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tenant Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAddTenantButton(context),
                ],
              )
            : Row(
                children: [
                   Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tenant Management',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Manage businesses and their subscriptions',
                          style: TextStyle(fontSize: 15, color: theme.textTheme.bodySmall?.color),
                        ),
                      ],
                    ),
                  ),
                  _buildAddTenantButton(context),
                ],
              ),

        const SizedBox(height: 28),

        // ── Stat Cards ──────────────────────────────────────────────────────
        BlocBuilder<TenantBloc, TenantState>(
          builder: (context, state) {
            int totalTenants = 0;
            int activeTenants = 0;
            double mrr = 0.0;

            if (state is TenantLoaded) {
              totalTenants = state.tenantResponse.totalTenants;
              activeTenants = state.tenantResponse.activeTenants;
              mrr = state.tenantResponse.mrr;
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final cards = [
                  CustomStatCard(
                    label: 'Total Tenant',
                    value: '$totalTenants',
                    iconPath: "assets/tenant.svg",
                  ),
                  CustomStatCard(
                    label: 'Active Tenant',
                    value: '$activeTenants',
                    iconPath: "assets/active.svg",
                  ),
                  CustomStatCard(
                    label: 'MRR',
                    value: '\$${mrr.toStringAsFixed(1)}',
                    iconPath: "assets/MRR.svg",
                  ),
                ];
                return isWide
                    ? Row(
                        children: cards
                            .map((c) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: cards.indexOf(c) < 2 ? 16 : 0),
                                    child: c,
                                  ),
                                ))
                            .toList(),
                      )
                    : Column(
                        children: cards
                            .map((c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: c,
                                ))
                            .toList(),
                      );
              },
            );
          },
        ),

        const SizedBox(height: 28),

        // ── Tenant List Table ────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table header row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tenant List',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'View and manage all business tenant',
                            style: TextStyle(
                                fontSize: 13, color: theme.textTheme.bodySmall?.color),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Search businesses...',
                          prefixIcon: const Icon(Icons.search),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.5)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Column headers
              if (isDesktop)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? theme.colorScheme.surface : AppColor.secondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: CustomHeadder(label: 'Business Name')),
                      Expanded(
                          flex: 3,
                          child: CustomHeadder(label: 'Owner Name')),
                      Expanded(
                          flex: 4, child: CustomHeadder(label: 'Contact')),
                      Expanded(flex: 2, child: CustomHeadder(label: 'Plan', textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: CustomHeadder(label: 'Status', textAlign: TextAlign.center)),
                      Expanded(
                          flex: 1,
                          child: CustomHeadder(label: 'Plan Price', textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: CustomHeadder(label: 'Actions', textAlign: TextAlign.center)),
                    ],
                  ),
                ),

              // Rows
              BlocBuilder<TenantBloc, TenantState>(
                builder: (context, state) {
                  if (state is TenantLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is TenantError) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(state.message, style: const TextStyle(color: Colors.red)),
                      ),
                    );
                  } else if (state is TenantLoaded) {
                    final tenants = state.tenantResponse.businesses;
                    if (tenants.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text("No businesses found.")),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tenants.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: theme.dividerTheme.color),
                      itemBuilder: (context, index) {
                        final t = tenants[index];
                        return isDesktop ? _buildRow(t, index) : _buildMobileCard(t, index);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRow(TenantBusiness tenant, int index) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              tenant.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              tenant.owner != null ? '${tenant.owner!.firstName ?? ''} ${tenant.owner!.lastName ?? ''}'.trim() : 'N/A',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenant.email ?? 'No email',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tenant.phone ?? 'No phone',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              tenant.planCycle ?? 'N/A',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _buildStatusLabel(tenant.status ?? 'Unknown')),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '\$${((tenant.planCycle?.toUpperCase() == 'YEARLY') ? (tenant.yearlyPrice ?? 0) : (tenant.monthlyPrice ?? 0)).toInt()}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: Icon(Icons.smart_toy_outlined, color: AppColor.primary, size: 20),
                  onPressed: () {
                    if (widget.onNavigateToAiAgent != null) {
                      widget.onNavigateToAiAgent!(tenant.id);
                    }
                  },
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: Icon(Icons.remove_red_eye, color: theme.textTheme.bodySmall?.color, size: 20),
                  onPressed: () => _showClientDetailsDialog(tenant),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _showEditTenantDialog(tenant),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _showDeleteTenantDialog(tenant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTenantButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const CustomAddtenant(),
        );
      },
      icon: const Icon(Icons.add, color: Colors.white, size: 18),
      label: const Text(
        'Add Tenant',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildMobileCard(TenantBusiness tenant, int index) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tenant.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              _buildStatusLabel(tenant.status ?? 'Unknown'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Owner: ${tenant.owner != null ? '${tenant.owner!.firstName ?? ''} ${tenant.owner!.lastName ?? ''}'.trim() : 'N/A'}",
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            tenant.email ?? 'No email',
            style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Plan",
                    style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                  ),
                  Text(
                    tenant.planCycle ?? 'N/A',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price",
                    style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                  ),
                  Text(
                    '\$${((tenant.planCycle?.toUpperCase() == 'YEARLY') ? (tenant.yearlyPrice ?? 0) : (tenant.monthlyPrice ?? 0)).toInt()}',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(Icons.smart_toy_outlined, color: AppColor.primary, size: 20),
                    onPressed: () {
                      if (widget.onNavigateToAiAgent != null) {
                        widget.onNavigateToAiAgent!(tenant.id);
                      }
                    },
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: Icon(Icons.visibility, color: theme.textTheme.bodySmall?.color, size: 20),
                    onPressed: () => _showClientDetailsDialog(tenant),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: () => _showEditTenantDialog(tenant),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _showDeleteTenantDialog(tenant),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'ACTIVE':
        bgColor = isDark ? const Color(0xFF1B5E20).withOpacity(0.2) : const Color(0xffD1FAE5);
        textColor = isDark ? const Color(0xFF81C784) : const Color(0xff065F46);
        break;
      case 'SUSPENDED':
        bgColor = isDark ? const Color(0xFFB71C1C).withOpacity(0.2) : const Color(0xFFFFEBEE);
        textColor = isDark ? const Color(0xFFE57373) : const Color(0xff991B1B);
        break;
      default:
        bgColor = isDark ? Colors.grey.withOpacity(0.2) : Colors.grey.shade100;
        textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: textColor.withOpacity(0.3)) : null,
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }



  void _showClientDetailsDialog(TenantBusiness tenant) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final width = MediaQuery.of(context).size.width;
        return Dialog(
          backgroundColor: theme.cardTheme.color,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: width < 600 ? width * 0.9 : 600,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Client Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 20, color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'View and manage client account information',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: theme.dividerTheme.color),
                const SizedBox(height: 16),
                width < 500
                    ? Column(
                        children: [
                          CustomBuilditem(
                              label: 'Business Name',
                              value: tenant.name),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Owner', value: tenant.owner != null ? '${tenant.owner!.firstName ?? ''} ${tenant.owner!.lastName ?? ''}'.trim() : 'N/A'),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Email', value: tenant.email ?? 'N/A'),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Phone', value: tenant.phone ?? 'N/A'),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Plan Cycle', value: tenant.planCycle ?? 'N/A'),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Status', value: tenant.status ?? 'N/A'),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Industry', value: tenant.industry ?? 'N/A'),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Joined Date', value: tenant.createdAt ?? 'N/A'),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Business Name',
                                    value: tenant.name),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Owner', value: tenant.owner != null ? '${tenant.owner!.firstName ?? ''} ${tenant.owner!.lastName ?? ''}'.trim() : 'N/A'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Email', value: tenant.email ?? 'N/A'),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Phone', value: tenant.phone ?? 'N/A'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Plan Cycle', value: tenant.planCycle ?? 'N/A'),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Status', value: tenant.status ?? 'N/A'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Industry',
                                    value: tenant.industry ?? 'N/A'),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Joined Date',
                                    value: tenant.createdAt ?? 'N/A'),
                              ),
                            ],
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      context.read<TenantBloc>().add(DeleteTenantRequested(businessId: tenant.id));
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete Business'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteTenantDialog(TenantBusiness tenant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tenant'),
        content: Text('Are you sure you want to delete ${tenant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<TenantBloc>().add(DeleteTenantRequested(businessId: tenant.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditTenantDialog(TenantBusiness tenant) {
    showDialog(
      context: context,
      builder: (context) => CustomAddtenant(tenant: tenant),
    );
  }
}

