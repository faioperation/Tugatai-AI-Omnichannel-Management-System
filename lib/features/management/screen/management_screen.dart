import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/management/widget/custom_addbranch.dart';
import 'package:roberto/features/management/widget/custom_adduser.dart';
import 'package:roberto/features/management/widget/custom_usermanagement.dart';
import 'package:roberto/features/management/widget/custom_branchmanagement.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isMobile),
          const SizedBox(height: 25),
          _buildToggleTabs(context, isMobile),
          const SizedBox(height: 25),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: _selectedTab == 0
                ? const CustomBranchmanagement(
                    key: ValueKey('Branch Management'))
                : const CustomUsermanagement(key: ValueKey('User Management')),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedTab == 0 ? 'Branch Management' : 'User Management',
          style: TextStyle(
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _selectedTab == 0 ? 'Manage your business locations and branches' : 'Manage your business users and permissions',
          style: TextStyle(
            fontSize: isMobile ? 13 : 15,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );

    final addBtn = InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _selectedTab == 0 ? const CustomAddbranch() : const CustomAdduser(),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: isMobile ? 16 : 18),
            const SizedBox(width: 6),
            Text(
              _selectedTab == 0 ? "Add Branch" : "Add User",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 12),
        addBtn,
      ],
    );
  }

  Widget _buildToggleTabs(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTab(context, index: 0, label: 'Branch Management'),
            _buildTab(context, index: 1, label: 'User Management'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, {
    required int index,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isActive = _selectedTab == index;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}