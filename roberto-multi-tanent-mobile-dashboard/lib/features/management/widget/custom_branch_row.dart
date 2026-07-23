import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/management/widget/custom_addbranch.dart';
import 'package:roberto/features/management/data/models/branch_model.dart';
import 'package:roberto/features/management/bloc/management_bloc.dart';
import 'package:roberto/features/management/bloc/management_event.dart';

class CustomBranchRow extends StatelessWidget {
  final String slNo;
  final BranchModel branch;
  final bool isMobile;

  const CustomBranchRow({
    super.key,
    required this.slNo,
    required this.branch,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isMobile) {
      return _buildMobileCard(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          // SL No
          Expanded(
            flex: 1,
            child: Text(slNo, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface)),
          ),

          // Name
          Expanded(
            flex: 2,
            child: Text(branch.name,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: theme.colorScheme.onSurface)),
          ),

          // Location
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.location_on, size: 14, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    branch.address,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Contact (Manager)
          Expanded(
            flex: 2,
            child: Text(branch.manager?.name ?? 'No Manager', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface)),
          ),

          // Phone
          Expanded(
            flex: 2,
            child: Text(branch.phone, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface)),
          ),

          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionIcon(Icons.edit_outlined, Colors.blue, () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomAddbranch(
                      isEdit: true,
                      branch: branch,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.delete_outline, Colors.red, () {
                  _showDeleteConfirmation(context);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
        boxShadow: !isDark ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                slNo,
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            branch.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(branch.address, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Text(branch.manager?.name ?? 'No Manager', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Text(branch.phone, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: theme.dividerTheme.color),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionIcon(Icons.edit_outlined, Colors.blue, () {
                showDialog(
                  context: context,
                  builder: (context) => CustomAddbranch(
                    isEdit: true,
                    branch: branch,
                  ),
                );
              }),
              const SizedBox(width: 12),
              _buildActionIcon(Icons.delete_outline, Colors.red, () {
                _showDeleteConfirmation(context);
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Delete Branch"),
        content: Text("Are you sure you want to delete '${branch.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<ManagementBloc>().add(DeleteBranchRequested(id: branch.id));
              Navigator.pop(dialogCtx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}