import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/management/widget/custom_branch_row.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_headder.dart';

class CustomBranchmanagement extends StatefulWidget {
  const CustomBranchmanagement({super.key});

  @override
  State<CustomBranchmanagement> createState() => _CustomBranchmanagementState();
}

class _CustomBranchmanagementState extends State<CustomBranchmanagement> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Branch List",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "View and manage all your business branches",
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          isDesktop ? _buildDesktopTable(context) : _buildMobileList(),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: isDark ? theme.colorScheme.surface : AppColor.secondary,
              child: const Row(
                children: [
                   Expanded(flex: 1, child: CustomHeadder(label: 'Sr.')),
                   Expanded(flex: 2, child: CustomHeadder(label: 'Branch Name')),
                   Expanded(flex: 2, child: CustomHeadder(label: 'Location')),
                   Expanded(flex: 2, child: CustomHeadder(label: 'Manager')),
                   Expanded(flex: 2, child: CustomHeadder(label: 'Status', textAlign: TextAlign.center)),
                   Expanded(flex: 1, child: CustomHeadder(label: 'Actions', textAlign: TextAlign.center)),
                ],
              ),
            ),
            _buildRows(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return _buildRows(isMobile: true);
  }

  Widget _buildRows({bool isMobile = false}) {
    final branches = [
      {
        "slNo": "001",
        "businessname": "Tugatai",
        "location": "New York, NY",
        "name": "John Smith",
        "status": "active"
      },
      {
        "slNo": "002",
        "businessname": "Tugatai",
        "location": "New York, NY",
        "name": "John Smith",
        "status": "active"
      },
      {
        "slNo": "003",
        "businessname": "Tugatai",
        "location": "New York, NY",
        "name": "John Smith",
        "status": "active"
      },
      {
        "slNo": "004",
        "businessname": "Tugatai",
        "location": "New York, NY",
        "name": "John Smith",
        "status": "inactive"
      },
    ];

    return Column(
      children: branches
          .map((b) => CustomBranchRow(
                slNo: b["slNo"]!,
                businessname: b["businessname"]!,
                location: b["location"]!,
                name: b["name"]!,
                status: b["status"]!,
                isMobile: isMobile,
              ))
          .toList(),
    );
  }
}
