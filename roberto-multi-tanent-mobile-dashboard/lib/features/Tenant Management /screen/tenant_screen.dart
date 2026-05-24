import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_stat_card.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/Custom_Addtenant.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_headder.dart';

import '../widget/custom_builditem.dart';

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  final List<Map<String, String>> _tenants = [
    {
      'business': 'Fashion Boutique',
      'owner': 'Sarah Johnson',
      'email': 'sarah@fashionboutique.com',
      'phone': '+1 234 567 8901',
      'plan': 'Half Moon',
      'status': 'Active',
      'price': '\$199',
    },
    {
      'business': 'TechGear Store',
      'owner': 'Michael Chen',
      'email': 'michael@techgear.com',
      'phone': '+1 234 567 8902',
      'plan': 'Full Moon',
      'status': 'Active',
      'price': '\$499',
    },
    {
      'business': 'Organic Foods Co',
      'owner': 'Emma Wilson',
      'email': 'emma@organicfoods.com',
      'phone': '+1 234 567 8903',
      'plan': 'Moon Enterprise',
      'status': 'Active',
      'price': '\$0',
    },
    {
      'business': 'Home Decor Hub',
      'owner': 'David Brown',
      'email': 'david@homedecor.com',
      'phone': '+1 234 567 8904',
      'plan': 'Half Moon',
      'status': 'Suspended',
      'price': '\$199',
    },
  ];

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
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final cards = [
              CustomStatCard(
                label: 'Total Tenant',
                value: '47',
                iconPath: "assets/tenant.svg",
              ),
              CustomStatCard(
                label: 'Active Tenant',
                value: '38',
                iconPath: "assets/active.svg",
              ),
              CustomStatCard(
                label: 'MRR',
                value: '\$8.9K',
                iconPath: "assets/MRR.svg",
              ),
            ];
            return isWide
                ? Row(
              children: cards
                  .map((c) =>
                  Expanded(
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
                  .map((c) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: c,
                  ))
                  .toList(),
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
                  ],
                ),
              ),

              // Column headers
              if (isDesktop)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  color: theme.brightness == Brightness.dark ? theme.colorScheme.surface : AppColor.secondary,
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
                          flex: 2,
                          child: CustomHeadder(label: 'Plan Price', textAlign: TextAlign.center)),
                      Expanded(
                          flex: 1,
                          child: CustomHeadder(label: 'Actions', textAlign: TextAlign.center)),
                    ],
                  ),
                ),

              // Rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tenants.length,
                separatorBuilder: (context, index) =>
                Divider(
                    height: 1, color: theme.dividerTheme.color),
                itemBuilder: (context, index) {
                  final t = _tenants[index];
                  return isDesktop ? _buildRow(t, index) : _buildMobileCard(t, index);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRow(Map<String, String> tenant, int index) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              tenant['business']!,
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
              tenant['owner']!,
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
                  tenant['email']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tenant['phone']!,
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
              tenant['plan']!,
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
            child: Center(child: _buildStatusDropdown(tenant, index)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              tenant['price']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.remove_red_eye, color: theme.textTheme.bodySmall?.color),
                onPressed: () => _showClientDetailsDialog(tenant),
              ),
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

  Widget _buildMobileCard(Map<String, String> tenant, int index) {
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
                tenant['business']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              _buildStatusDropdown(tenant, index),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Owner: ${tenant['owner']}",
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            tenant['email']!,
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
                    tenant['plan']!,
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
                    tenant['price']!,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.visibility, color: theme.textTheme.bodySmall?.color, size: 20),
                onPressed: () => _showClientDetailsDialog(tenant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(Map<String, String> tenant, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = tenant['status']!;

    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Active':
        bgColor = isDark ? const Color(0xFF1B5E20).withOpacity(0.2) : const Color(0xffD1FAE5);
        textColor = isDark ? const Color(0xFF81C784) : const Color(0xff065F46);
        break;
      case 'Suspended':
        bgColor = isDark ? const Color(0xFFB71C1C).withOpacity(0.2) : const Color(0xFFFFEBEE);
        textColor = isDark ? const Color(0xFFE57373) : const Color(0xff991B1B);
        break;
      case 'Inactive':
      default:
        bgColor = isDark ? Colors.grey.withOpacity(0.2) : Colors.grey.shade100;
        textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
        break;
    }

    return PopupMenuButton<String>(
      onSelected: (String newStatus) {
        setState(() {
          _tenants[index]['status'] = newStatus;
          // In a real app, you'd calculate price based on status/plan here
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildPopupItem('Active', isDark),
        _buildPopupItem('Inactive', isDark),
        _buildPopupItem('Suspended', isDark),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: textColor.withOpacity(0.3)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 14, color: textColor),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, bool isDark) {
    return PopupMenuItem<String>(
      value: value,
      height: 32,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  void _showClientDetailsDialog(Map<String, String> tenant) {
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
                              value: tenant['business']!),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Owner', value: tenant['owner']!),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Email', value: tenant['email']!),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Phone', value: tenant['phone']!),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Plan', value: tenant['plan']!),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Status', value: tenant['status']!),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Monthly Revenue', value: tenant['price']!),
                          const SizedBox(height: 14),
                          CustomBuilditem(
                              label: 'Joined Date', value: 'Jan 15, 2024'),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Business Name',
                                    value: tenant['business']!),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Owner', value: tenant['owner']!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Email', value: tenant['email']!),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Phone', value: tenant['phone']!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Plan', value: tenant['plan']!),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Status', value: tenant['status']!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Monthly Revenue',
                                    value: tenant['price']!),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomBuilditem(
                                    label: 'Joined Date',
                                    value: 'Jan 15, 2024'),
                              ),
                            ],
                          ),
                        ],
                      ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
