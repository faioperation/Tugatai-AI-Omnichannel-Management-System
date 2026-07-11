import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/WhatsAppCampaigns/data/repositories/campaign_repository.dart';
import 'package:roberto/features/management/data/models/branch_model.dart';
import 'package:intl/intl.dart';

class CreateCampaignForm extends StatefulWidget {
  final VoidCallback onCancel;
  final void Function(Map<String, dynamic> data) onCreate;
  final bool isReadOnly;
  final dynamic initialData;
  final List<BranchModel> branches;
  final String? currentBranchId;
  final bool isBranchManager;
  final CampaignRepository? campaignRepository;

  const CreateCampaignForm({
    super.key,
    required this.onCancel,
    required this.onCreate,
    this.isReadOnly = false,
    this.initialData,
    this.branches = const [],
    this.currentBranchId,
    this.isBranchManager = false,
    this.campaignRepository,
  });

  @override
  State<CreateCampaignForm> createState() => _CreateCampaignFormState();
}

class _CreateCampaignFormState extends State<CreateCampaignForm> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedAudience;
  String? _selectedBranch;
  DateTime? _scheduledTime;
  DateTime? _endDate;

  // Country & ProductType
  List<String> _countries = [];
  List<String> _productTypes = [];
  String? _selectedCountry;
  String? _selectedProductType;
  bool _loadingCountries = false;
  bool _loadingProductTypes = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!.title;
      _messageController.text = widget.initialData!.message ?? '';
      _selectedBranch = widget.initialData!.branchId;
      if (widget.initialData!.selectedPeople != null && widget.initialData!.selectedPeople!.isNotEmpty) {
        String firstAudience = widget.initialData!.selectedPeople!.first;
        _selectedAudience = ["Cold", "Warm", "Hot", "Booked", "Completed"].firstWhere(
          (e) => e.toUpperCase() == firstAudience.toUpperCase(), 
          orElse: () => "Cold"
        );
      }
      _scheduledTime = widget.initialData!.scheduledTime;
      _endDate = widget.initialData!.endDate;
    } else {
      _selectedBranch = widget.currentBranchId;
      _scheduledTime = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
    }

    // Load countries and product types
    _loadCountriesAndProductTypes();
  }

  Future<void> _loadCountriesAndProductTypes() async {
    final repo = widget.campaignRepository;
    final branchId = widget.currentBranchId ?? '';
    if (repo == null || branchId.isEmpty) return;

    setState(() {
      _loadingCountries = true;
      _loadingProductTypes = true;
    });

    try {
      final countriesRes = await repo.getCampaignCountries(branchId, isBranchManagerOverride: widget.isBranchManager);
      if (mounted && countriesRes['success'] == true) {
        final List<dynamic> data = countriesRes['data'] ?? [];
        setState(() {
          _countries = data.map((e) => e.toString()).toList();
          _loadingCountries = false;
        });
      } else if (mounted) {
        setState(() => _loadingCountries = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingCountries = false);
    }

    try {
      final productTypesRes = await repo.getCampaignProductTypes(branchId, isBranchManagerOverride: widget.isBranchManager);
      if (mounted && productTypesRes['success'] == true) {
        final List<dynamic> data = productTypesRes['data'] ?? [];
        setState(() {
          _productTypes = data.map((e) => e.toString()).toList();
          _loadingProductTypes = false;
        });
      } else if (mounted) {
        setState(() => _loadingProductTypes = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingProductTypes = false);
    }
  }

  Future<void> _pickDateTime(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? (_scheduledTime ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
        final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          if (isStart) {
            _scheduledTime = combined;
          } else {
            _endDate = combined;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500, // Fixed width for dialog
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isReadOnly ? "View Campaign" : (widget.initialData != null ? "Edit Campaign" : "Create WhatsApp campaign"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel("Title"),
            TextFormField(
              controller: _titleController,
              readOnly: widget.isReadOnly,
              validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              decoration: _inputDecoration("Please enter the title of campaign"),
            ),
            const SizedBox(height: 20),
            _buildLabel("Select Branch"),
            DropdownButtonFormField<String>(
              value: _selectedBranch,
              items: widget.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
              onChanged: widget.isReadOnly ? null : (v) => setState(() => _selectedBranch = v),
              validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              decoration: _inputDecoration("Select Branch"),
            ),
            const SizedBox(height: 20),
            _buildLabel("Audience"),
            DropdownButtonFormField<String>(
              value: _selectedAudience,
              items: ["Cold", "Warm", "Hot", "Booked", "Completed"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: widget.isReadOnly ? null : (v) => setState(() => _selectedAudience = v),
              validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              decoration: _inputDecoration("Select the customer labels"),
            ),
            const SizedBox(height: 20),

            // ── Country ──────────────────────────────────────────────────
            _buildLabel("Country"),
            if (_loadingCountries)
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).hoverColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerTheme.color ?? AppColor.borderLight),
                ),
                child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            else
              DropdownButtonFormField<String>(
                value: _countries.contains(_selectedCountry) ? _selectedCountry : null,
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Select Country')),
                  ..._countries.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: widget.isReadOnly ? null : (v) => setState(() => _selectedCountry = v),
                decoration: _inputDecoration("Select Country"),
              ),
            const SizedBox(height: 20),

            // ── Product Type ─────────────────────────────────────────────
            _buildLabel("Product Type"),
            if (_loadingProductTypes)
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).hoverColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerTheme.color ?? AppColor.borderLight),
                ),
                child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            else
              DropdownButtonFormField<String>(
                value: _productTypes.contains(_selectedProductType) ? _selectedProductType : null,
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Select Product Type')),
                  ..._productTypes.map((pt) => DropdownMenuItem(value: pt, child: Text(pt))),
                ],
                onChanged: widget.isReadOnly ? null : (v) => setState(() => _selectedProductType = v),
                decoration: _inputDecoration("Select Product Type"),
              ),
            const SizedBox(height: 20),

            _buildLabel("Message"),
            TextFormField(
              controller: _messageController,
              readOnly: widget.isReadOnly,
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              decoration: _inputDecoration("Please enter the campaign message"),
            ),
            const SizedBox(height: 20),
            _buildLabel("Scheduled Time"),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _scheduledTime != null ? DateFormat('dd/MM/yyyy, HH:mm').format(_scheduledTime!) : '',
              ),
              validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              decoration: _inputDecoration("dd/mm/yyyy, --:--").copyWith(
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              onTap: widget.isReadOnly ? null : () => _pickDateTime(context, true),
            ),
            const SizedBox(height: 20),
            _buildLabel("End Date"),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _endDate != null ? DateFormat('dd/MM/yyyy, HH:mm').format(_endDate!) : '',
              ),
              validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
              decoration: _inputDecoration("dd/mm/yyyy, --:--").copyWith(
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              onTap: widget.isReadOnly ? null : () => _pickDateTime(context, false),
            ),
            const SizedBox(height: 32),
            if (!widget.isReadOnly)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.transparent),
                        backgroundColor: Theme.of(context).hoverColor,
                      ),
                      child: Text("Cancel", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        
                        if (_selectedBranch == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a branch')));
                          return;
                        }
                        String aud = _selectedAudience?.toUpperCase() ?? 'COLD';
                        widget.onCreate({
                          'title': _titleController.text,
                          'message': _messageController.text,
                          'branchId': _selectedBranch,
                          'selectedPeople': [aud],
                          'scheduledTime': _scheduledTime ?? DateTime.now(),
                          'endDate': _endDate ?? DateTime.now().add(const Duration(days: 7)),
                          'country': _selectedCountry,
                          'productType': _selectedProductType,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(widget.initialData != null ? "Update" : "Create", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 14),
      filled: true,
      fillColor: Theme.of(context).hoverColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerTheme.color ?? AppColor.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
    );
  }
}
