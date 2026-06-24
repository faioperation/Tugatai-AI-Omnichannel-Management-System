import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';
import 'package:roberto/features/management/data/models/branch_model.dart';
import 'package:roberto/features/management/data/models/branch_manager_model.dart';
import 'package:roberto/features/management/bloc/management_bloc.dart';
import 'package:roberto/features/management/bloc/management_event.dart';
import 'package:roberto/features/management/bloc/management_state.dart';

class CustomAddbranch extends StatefulWidget {
  final bool isEdit;
  final BranchModel? branch;

  const CustomAddbranch({
    super.key,
    this.isEdit = false,
    this.branch,
  });

  @override
  State<CustomAddbranch> createState() => _CustomAddbranchState();
}

class _CustomAddbranchState extends State<CustomAddbranch> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedManagerId;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.branch != null) {
      _nameController.text = widget.branch!.name;
      _emailController.text = widget.branch!.email;
      _phoneController.text = widget.branch!.phone;
      _addressController.text = widget.branch!.address;
      _selectedManagerId = widget.branch!.managerId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
                controller: _nameController,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel(context, "Branch Email"),
              CustomTextfield(
                hintText: "branch@example.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel(context, "Branch Phone"),
              CustomTextfield(
                hintText: "+1234567890",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel(context, "Address"),
              CustomTextfield(
                hintText: "123 Business Rd, City",
                controller: _addressController,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel(context, "Assign Branch Manager"),
              _buildBranchManagerDropdown(theme),
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

  Widget _buildBranchManagerDropdown(ThemeData theme) {
    return BlocBuilder<ManagementBloc, ManagementState>(
      builder: (context, state) {
        List<BranchManagerModel> managers = [];
        if (state is ManagementLoaded) {
          managers = state.managers;
        }

        // Validate selection selection is present in current managers
        final hasSelected = managers.any((m) => m.id == _selectedManagerId);
        if (!hasSelected && managers.isNotEmpty) {
          // If we had no selection, we can pre-select if desired.
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : const Color(0xffF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedManagerId,
              hint: Text(
                "Select Branch Manager",
                style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color),
              ),
              isExpanded: true,
              dropdownColor: theme.cardTheme.color,
              items: managers
                  .map((m) => DropdownMenuItem<String>(
                        value: m.id,
                        child: Text(
                          m.name,
                          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedManagerId = v);
              },
            ),
          ),
        );
      },
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

    final submitBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: () {
        final name = _nameController.text.trim();
        final email = _emailController.text.trim();
        final phone = _phoneController.text.trim();
        final address = _addressController.text.trim();
        final managerId = _selectedManagerId ?? '';

        if (name.isEmpty || email.isEmpty || phone.isEmpty || address.isEmpty || managerId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("All fields are required. Please select a manager."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (widget.isEdit && widget.branch != null) {
          context.read<ManagementBloc>().add(UpdateBranchRequested(
                id: widget.branch!.id,
                name: name,
                email: email,
                phone: phone,
                address: address,
                managerId: managerId,
              ));
        } else {
          context.read<ManagementBloc>().add(CreateBranchRequested(
                name: name,
                email: email,
                phone: phone,
                address: address,
                managerId: managerId,
              ));
        }
        Navigator.pop(context);
      },
      child: Center(
        child: Text(
          widget.isEdit ? "Update Branch" : "Create Branch",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          submitBtn,
          const SizedBox(height: 12),
          cancelBtn,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cancelBtn),
        const SizedBox(width: 12),
        Expanded(child: submitBtn),
      ],
    );
  }
}