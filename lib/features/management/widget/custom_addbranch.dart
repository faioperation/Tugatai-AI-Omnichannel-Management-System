import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';

class CustomAddbranch extends StatefulWidget {
  final bool isEdit;
  final String? branchName;
  final String? location;
  final String? address;
  final String? status;

  const CustomAddbranch({
    super.key,
    this.isEdit = false,
    this.branchName,
    this.location,
    this.address,
    this.status,
  });

  @override
  State<CustomAddbranch> createState() => _CustomAddbranchState();
}

class _CustomAddbranchState extends State<CustomAddbranch> {
  String _selectedStatus = "Active";
  String? _selectedBranchManager;

  @override
  void initState() {
    super.initState();
    if (widget.status != null) {
      // Normalize to match dropdown items ["Active", "Inactive"]
      final status = widget.status!.toLowerCase();
      if (status == 'active') {
        _selectedStatus = "Active";
      } else if (status == 'inactive') {
        _selectedStatus = "Inactive";
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;
    final bool isMobile = width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.cardTheme.color,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: isDesktop ? 500 : width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, isMobile),
              const SizedBox(height: 24),

              // Form Fields
              _buildFieldLabel(context, "Branch Name"),
              CustomTextfield(
                hintText: "Main Branch",
                initialValue: widget.branchName,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel(context, "Location"),
              CustomTextfield(
                hintText: "Dhaka, Bangladesh",
                initialValue: widget.location,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel(context, "Address"),
              CustomTextfield(
                hintText: "123 Street Name, Area",
                initialValue: widget.address,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel(context, "Assign Branch Manager"),
              _buildBranchManagerDropdown(theme),
              const SizedBox(height: 16),

              _buildFieldLabel(context, "Status"),
              _buildStatusDropdown(theme),
              const SizedBox(height: 24),

              // Actions
              _buildActions(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEdit ? "Update Branch" : "Create New Branch",
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isEdit ? "Update branch location details" : "Add a new business location",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: theme.textTheme.bodySmall?.color, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          dropdownColor: theme.cardTheme.color,
          items: ["Active", "Inactive"]
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s,
                        style: TextStyle(
                            fontSize: 14, color: theme.colorScheme.onSurface)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => _selectedStatus = v);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBranchManagerDropdown(ThemeData theme) {
    // These would normally come from a provider/state management
    final branchManagers = ["John Smith", "Michael Chen", "Sarah Johnson", "David Brown"];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBranchManager,
          hint: Text("Select Branch Manager", style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color)),
          isExpanded: true,
          dropdownColor: theme.cardTheme.color,
          items: branchManagers
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m,
                        style: TextStyle(
                            fontSize: 14, color: theme.colorScheme.onSurface)),
                  ))
              .toList(),
          onChanged: (v) {
            setState(() => _selectedBranchManager = v);
          },
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cancelBtn = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade300),
        backgroundColor: isDark ? theme.colorScheme.surface : Colors.transparent,
      ),
      onPressed: () => Navigator.pop(context),
      child: Center(
        child: Text(
          "Cancel",
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
      ),
    );

    final createBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: () => Navigator.pop(context),
      child: Center(
        child: Text(
          widget.isEdit ? "Update branch" : "Create branch",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          createBtn,
          const SizedBox(height: 12),
          cancelBtn,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cancelBtn),
        const SizedBox(width: 12),
        Expanded(child: createBtn),
      ],
    );
  }
}