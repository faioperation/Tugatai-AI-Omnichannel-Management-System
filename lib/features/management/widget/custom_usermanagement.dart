import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/management/widget/custom_user_row.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_headder.dart';
import 'package:roberto/features/management/bloc/management_bloc.dart';
import 'package:roberto/features/management/bloc/management_event.dart';
import 'package:roberto/features/management/bloc/management_state.dart';
import 'package:roberto/features/management/data/models/branch_manager_model.dart';

class CustomUsermanagement extends StatefulWidget {
  const CustomUsermanagement({super.key});

  @override
  State<CustomUsermanagement> createState() => _CustomUsermanagementState();
}

class _CustomUsermanagementState extends State<CustomUsermanagement> {
  @override
  void initState() {
    super.initState();
    context.read<ManagementBloc>().add(FetchBranchManagersRequested());
  }

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
            "User List",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "View and manage all system users",
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          BlocConsumer<ManagementBloc, ManagementState>(
            listener: (context, state) {
              if (state is ManagementOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is ManagementError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              if (state is ManagementLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ManagementLoaded) {
                if (state.managers.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("No Branch Managers found"),
                    ),
                  );
                }
                return isDesktop ? _buildDesktopTable(context, state.managers) : _buildMobileList(state.managers);
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<BranchManagerModel> managers) {
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
                  Expanded(flex: 2, child: CustomHeadder(label: 'User Name')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Email')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Status', textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: CustomHeadder(label: 'Actions', textAlign: TextAlign.center)),
                ],
              ),
            ),
            _buildRows(managers: managers),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(List<BranchManagerModel> managers) {
    return _buildRows(managers: managers, isMobile: true);
  }

  Widget _buildRows({required List<BranchManagerModel> managers, bool isMobile = false}) {
    return Column(
      children: managers.asMap().entries.map((entry) {
        final index = entry.key;
        final manager = entry.value;
        return CustomUserRow(
          slNo: (index + 1).toString().padLeft(3, '0'),
          manager: manager,
          isMobile: isMobile,
        );
      }).toList(),
    );
  }
}
