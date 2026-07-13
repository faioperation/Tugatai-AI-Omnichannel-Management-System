import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';
import 'package:roberto/features/CRM/bloc/crm_bloc.dart';
import 'package:roberto/features/CRM/bloc/crm_event.dart';
import 'package:roberto/features/CRM/data/models/crm_lead_model.dart';
import 'package:roberto/common/user_role.dart';

class CustomUpdateLead extends StatefulWidget {
  final CrmLeadModel lead;
  final UserRole role;

  const CustomUpdateLead({super.key, required this.lead, this.role = UserRole.businessOwner});

  @override
  State<CustomUpdateLead> createState() => _CustomUpdateLeadState();
}

class _CustomUpdateLeadState extends State<CustomUpdateLead> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _sourceController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;
  late TextEditingController _statusController;
  
  // Metadata controllers
  late TextEditingController _companyNameController;
  late TextEditingController _industryController;
  late TextEditingController _studentCountController;
  late TextEditingController _budgetController;
  late TextEditingController _interestedServiceController;
  late TextEditingController _preferredContactMethodController;
  late TextEditingController _followUpDateController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lead.name);
    _emailController = TextEditingController(text: widget.lead.email);
    _phoneController = TextEditingController(text: widget.lead.phone);
    _sourceController = TextEditingController(text: widget.lead.source);
    _addressController = TextEditingController(text: widget.lead.address);
    _noteController = TextEditingController(text: widget.lead.note);
    _statusController = TextEditingController(text: widget.lead.status);

    final meta = widget.lead.metadata ?? {};
    _companyNameController = TextEditingController(text: meta['companyName']?.toString());
    _industryController = TextEditingController(text: meta['industry']?.toString());
    _studentCountController = TextEditingController(text: meta['studentCount']?.toString());
    _budgetController = TextEditingController(text: meta['budget']?.toString());
    _interestedServiceController = TextEditingController(text: meta['interestedService']?.toString());
    _preferredContactMethodController = TextEditingController(text: meta['preferredContactMethod']?.toString());
    _followUpDateController = TextEditingController(text: meta['followUpDate']?.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _sourceController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _statusController.dispose();
    
    _companyNameController.dispose();
    _industryController.dispose();
    _studentCountController.dispose();
    _budgetController.dispose();
    _interestedServiceController.dispose();
    _preferredContactMethodController.dispose();
    _followUpDateController.dispose();
    super.dispose();
  }

  void _updateLead() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.lead.id == null) return;

    final name = _nameController.text.trim();

    final metadata = {
      if (_companyNameController.text.isNotEmpty) 'companyName': _companyNameController.text.trim(),
      if (_industryController.text.isNotEmpty) 'industry': _industryController.text.trim(),
      if (_studentCountController.text.isNotEmpty) 'studentCount': int.tryParse(_studentCountController.text.trim()),
      if (_budgetController.text.isNotEmpty) 'budget': int.tryParse(_budgetController.text.trim()),
      if (_interestedServiceController.text.isNotEmpty) 'interestedService': _interestedServiceController.text.trim(),
      if (_preferredContactMethodController.text.isNotEmpty) 'preferredContactMethod': _preferredContactMethodController.text.trim(),
      if (_followUpDateController.text.isNotEmpty) 'followUpDate': _followUpDateController.text.trim(),
    };

    context.read<CrmBloc>().add(UpdateLead(
      id: widget.lead.id!,
      // preserving branch id
      branchId: widget.lead.branchId,
      name: name,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      source: _sourceController.text.trim(),
      address: _addressController.text.trim(),
      note: _noteController.text.trim(),
      status: _statusController.text.trim().isEmpty ? 'WARM' : _statusController.text.trim(),
      metadata: metadata,
      role: widget.role,
    ));

    Navigator.pop(context); // close dialog
    // also pop the detail view if you want, or let it be. We will just close the edit dialog.
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
                "Update Lead",
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
            "Modify lead details",
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
                hintText: "Name",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Email"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _emailController, 
                hintText: "Email",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Phone"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _phoneController, 
                hintText: "Phone",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Source (e.g. REFERRAL)"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _sourceController, 
                hintText: "Source",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Address"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _addressController, 
                hintText: "Address",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 15),

              const Text("Note"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _noteController, 
                hintText: "Note",
                validator: (v) => null,
              ),

              const SizedBox(height: 15),
              
              const Text("Status (e.g. WARM)"),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: _statusController, 
                hintText: "Status",
                validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              ),

              const SizedBox(height: 25),
              Text("Metadata", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              const SizedBox(height: 10),

              const Text("Company Name"),
              const SizedBox(height: 6),
              CustomTextfield(controller: _companyNameController, hintText: "Company Name"),
              const SizedBox(height: 15),

              const Text("Industry"),
              const SizedBox(height: 6),
              CustomTextfield(controller: _industryController, hintText: "Industry"),
              const SizedBox(height: 15),

              const Text("Student Count"),
              const SizedBox(height: 6),
              CustomTextfield(controller: _studentCountController, hintText: "number"),
              const SizedBox(height: 15),

              const Text("Budget"),
              const SizedBox(height: 6),
              CustomTextfield(controller: _budgetController, hintText: "number"),
              const SizedBox(height: 15),

              const Text("Interested Service"),
              const SizedBox(height: 6),
              CustomTextfield(controller: _interestedServiceController, hintText: "Service"),
              const SizedBox(height: 15),

              const Text("Preferred Contact Method"),
              const SizedBox(height: 6),
              CustomTextfield(controller: _preferredContactMethodController, hintText: "Phone/Email"),
              const SizedBox(height: 15),

              const Text("Follow Up Date"),
              const SizedBox(height: 6),
              CustomTextfield(controller: _followUpDateController, hintText: "YYYY-MM-DD"),
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
        onPressed: _updateLead,
        child: const Text(
          "Update",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 15),
    ];
  }
}
