import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/TenantManagement/widget/custom_headder.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import '../data/models/staff_user_model.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(FetchAllStaffRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is StaffOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is StaffError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "System Staff Management",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Create staff members and assign fine-grained permissions",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              BlocBuilder<StaffBloc, StaffState>(
                builder: (context, state) {
                  List<PermissionModel> availablePerms = [];
                  if (state is StaffLoaded) {
                    availablePerms = state.availablePermissions;
                  }
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showAddStaffDialog(context, availablePerms),
                    icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                    label: const Text(
                      "Add System Staff",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<StaffBloc, StaffState>(
            builder: (context, state) {
              if (state is StaffLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is StaffLoaded) {
                final staffList = state.staffUsers;
                return Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      _buildTableHeader(theme),
                      if (staffList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: Text("No System Staff members found")),
                        )
                      else
                        ...staffList.map((staff) => _buildRow(staff, state.availablePermissions, theme)),
                    ],
                  ),
                );
              } else if (state is StaffError) {
                return Center(
                  child: Text(state.message, style: const TextStyle(color: Colors.red)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? theme.colorScheme.surface : AppColor.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: CustomHeadder(label: 'Name')),
          Expanded(flex: 2, child: CustomHeadder(label: 'Email')),
          Expanded(flex: 1, child: CustomHeadder(label: 'Status')),
          Expanded(flex: 3, child: CustomHeadder(label: 'Assigned Permissions')),
          Expanded(flex: 1, child: CustomHeadder(label: 'Action', textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildRow(StaffUserModel staff, List<PermissionModel> availablePerms, ThemeData theme) {
    final assignedNames = staff.permissions.map((p) => p.name).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "${staff.firstName} ${staff.lastName ?? ''}".trim(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              staff.email,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  staff.status ?? 'ACTIVE',
                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: assignedNames.isEmpty
                  ? [
                      const Text(
                        "No Permissions Assigned (0)",
                        style: TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic),
                      )
                    ]
                  : assignedNames.map((name) {
                      return Chip(
                        label: Text(
                          name,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.indigo),
                        ),
                        backgroundColor: Colors.indigo.withOpacity(0.1),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => _showEditPermissionsDialog(context, staff, availablePerms),
                icon: const Icon(Icons.security, size: 16),
                label: const Text("Edit Perms", style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context, List<PermissionModel> availablePerms) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();

    // Map permission ID -> selected boolean
    final Map<String, bool> selectedPermIds = {
      for (var p in availablePerms) p.id: false
    };

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New System Staff"),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(labelText: "First Name *"),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(labelText: "Last Name"),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Email Address *"),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "Password *"),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: "Phone"),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Initial Permissions:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      ...availablePerms.map((perm) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(perm.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: perm.description != null ? Text(perm.description!, style: const TextStyle(fontSize: 11)) : null,
                          value: selectedPermIds[perm.id] ?? false,
                          onChanged: (val) {
                            setDialogState(() {
                              selectedPermIds[perm.id] = val ?? false;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                  onPressed: () {
                    if (emailController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        firstNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all required fields")),
                      );
                      return;
                    }

                    final selectedIds = selectedPermIds.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();

                    context.read<StaffBloc>().add(
                          CreateStaffRequested(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            firstName: firstNameController.text.trim(),
                            lastName: lastNameController.text.trim(),
                            phone: phoneController.text.trim(),
                            permissions: selectedIds,
                          ),
                        );
                    Navigator.pop(dialogCtx);
                  },
                  child: const Text("Create Staff", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditPermissionsDialog(
    BuildContext context,
    StaffUserModel staff,
    List<PermissionModel> availablePerms,
  ) {
    final currentPermIds = staff.permissions.map((p) => p.id).toSet();
    final Map<String, bool> selectedPermIds = {
      for (var p in availablePerms) p.id: currentPermIds.contains(p.id)
    };

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Edit Permissions: ${staff.firstName}"),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 480,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Check or uncheck permissions to dynamically assign or revoke access:",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      ...availablePerms.map((perm) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(perm.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: perm.description != null ? Text(perm.description!, style: const TextStyle(fontSize: 11)) : null,
                          value: selectedPermIds[perm.id] ?? false,
                          onChanged: (val) {
                            setDialogState(() {
                              selectedPermIds[perm.id] = val ?? false;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                  onPressed: () {
                    final selectedIds = selectedPermIds.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();

                    context.read<StaffBloc>().add(
                          UpdateStaffPermissionsRequested(
                            staffId: staff.id,
                            permissions: selectedIds,
                          ),
                        );
                    Navigator.pop(dialogCtx);
                  },
                  child: const Text("Save Permissions", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
