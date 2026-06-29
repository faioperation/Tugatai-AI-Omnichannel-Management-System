import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/management/widget/custom_branch_row.dart';
import 'package:roberto/features/TenantManagement%20/widget/custom_headder.dart';
import 'package:roberto/features/management/bloc/management_bloc.dart';
import 'package:roberto/features/management/bloc/management_event.dart';
import 'package:roberto/features/management/bloc/management_state.dart';
import 'package:roberto/features/management/data/models/branch_model.dart';

class CustomBranchmanagement extends StatefulWidget {
  const CustomBranchmanagement({super.key});

  @override
  State<CustomBranchmanagement> createState() => _CustomBranchmanagementState();
}

class _CustomBranchmanagementState extends State<CustomBranchmanagement> {
  @override
  void initState() {
    super.initState();
    context.read<ManagementBloc>().add(FetchBranchesRequested());
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
          BlocConsumer<ManagementBloc, ManagementState>(
            listener: (context, state) {
              if (state is ManagementOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is ManagementError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ManagementLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is ManagementLoaded) {
                if (state.branches.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        "No branches found. Click 'Add Branch' to create one.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }
                return isDesktop ? _buildDesktopTable(context, state.branches) : _buildMobileList(state.branches);
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<BranchModel> branches) {
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
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surface : AppColor.secondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 1, child: CustomHeadder(label: 'Sr.')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Branch Name')),
                  Expanded(flex: 3, child: CustomHeadder(label: 'Location')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Manager')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Phone')),
                  Expanded(flex: 1, child: CustomHeadder(label: 'Actions', textAlign: TextAlign.center)),
                ],
              ),
            ),
            _buildRows(branches: branches),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(List<BranchModel> branches) {
    return _buildRows(branches: branches, isMobile: true);
  }

  Widget _buildRows({required List<BranchModel> branches, bool isMobile = false}) {
    return Column(
      children: branches.asMap().entries.map((entry) {
        final index = entry.key;
        final branch = entry.value;
        return CustomBranchRow(
          slNo: (index + 1).toString().padLeft(3, '0'),
          branch: branch,
          isMobile: isMobile,
        );
      }).toList(),
    );
  }
}
