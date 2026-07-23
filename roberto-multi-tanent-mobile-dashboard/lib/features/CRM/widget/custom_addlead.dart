import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';
import 'package:roberto/features/CRM/bloc/crm_bloc.dart';
import 'package:roberto/features/CRM/bloc/crm_event.dart';
import 'package:roberto/common/user_role.dart';

class CustomAddlead extends StatefulWidget {
  final UserRole role;
  final String? branchId;
  const CustomAddlead({super.key, this.role = UserRole.businessOwner, this.branchId});

  @override
  State<CustomAddlead> createState() => _CustomAddleadState();
}

class _CustomAddleadState extends State<CustomAddlead> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedStatus = 'WARM';
  final List<String> _statusOptions = ['COLD', 'WARM', 'BOOKED', 'HOT'];

  final List<Map<String, TextEditingController>> _metadataFields = [];

  void _addMetadataField() {
    setState(() {
      _metadataFields.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
    });
  }

  void _removeMetadataField(int index) {
    final removedField = _metadataFields[index];
    setState(() {
      _metadataFields.removeAt(index);
    });
    // Delay disposal until after the UI rebuilds to prevent 'used after being disposed' errors
    Future.delayed(Duration.zero, () {
      removedField['key']?.dispose();
      removedField['value']?.dispose();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _sourceController.dispose();
    _noteController.dispose();
    _countryController.dispose();
    for (var field in _metadataFields) {
      field['key']?.dispose();
      field['value']?.dispose();
    }
    super.dispose();
  }

  void _createLead() {
    if (!_formKey.currentState!.validate()) return;
    
    if (widget.branchId == null || widget.branchId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a branch first'), backgroundColor: Colors.red),
      );
      return;
    }

    final name = _nameController.text.trim();
    
    final Map<String, dynamic> metadata = {};
    for (var field in _metadataFields) {
      final key = field['key']?.text.trim();
      final value = field['value']?.text.trim();
      if (key != null && key.isNotEmpty && value != null && value.isNotEmpty) {
        metadata[key] = value;
      }
    }

    context.read<CrmBloc>().add(CreateLead(
      branchId: widget.branchId!,
      name: name,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      source: _sourceController.text.trim().isEmpty ? 'Direct' : _sourceController.text.trim(),
      country: _countryController.text.trim(),
      address: '', 
      note: _noteController.text.trim(),
      status: _selectedStatus,
      metadata: metadata,
      role: widget.role,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;

    return AlertDialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16, vertical: 24),

      contentPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 20,
      ),

      titlePadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 16,
      ),

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add New Lead",
                style: TextStyle(fontSize: isDesktop ? 20 : 16),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: const Icon(Icons.close, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "Enter the lead details to add to your pipeline",
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: isDesktop ? 450 : double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Name"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _nameController,
                hintText: "Enter name",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Email"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _emailController,
                hintText: "email@example.com",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Phone"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _phoneController,
                hintText: "+1 234 567 8900",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Source"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _sourceController,
                hintText: "Facebook",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Country"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _countryController,
                hintText: "Enter country",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Note"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _noteController,
                hintText: "Add notes...",
                validator: (v) => null,
              ),

              const SizedBox(height: 15),

              const Text("Status"),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).dividerTheme.color!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).dividerTheme.color!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColor.primary),
                  ),
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedStatus = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Metadata", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _addMetadataField,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Add Field"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...List.generate(_metadataFields.length, (index) {
                return Padding(
                  key: ObjectKey(_metadataFields[index]['key']),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextfield(
                          controller: _metadataFields[index]['key'],
                          hintText: "Key",
                          validator: (v) => null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextfield(
                          controller: _metadataFields[index]['value'],
                          hintText: "Value",
                          validator: (v) => null,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeMetadataField(index),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 15),
            ],
          ),
        ),
        ),
      ),

      actionsPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 12,
        vertical: 10,
      ),

      actions: [
        isDesktop
            ? Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _buttons(),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buttons(),
        ),
      ],
    );
  }

  List<Widget> _buttons() {
    return [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).cardTheme.color,
          side: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          "Cancel",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      const SizedBox(width: 10, height: 10),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
        ),
        onPressed: _createLead,
        child: const Text(
          "Create",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 15),
    ];
  }
}