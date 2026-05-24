import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';

class CreateCampaignForm extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onCreate;
  final bool isReadOnly;
  final Map<String, dynamic>? initialData;

  const CreateCampaignForm({
    super.key,
    required this.onCancel,
    required this.onCreate,
    this.isReadOnly = false,
    this.initialData,
  });

  @override
  State<CreateCampaignForm> createState() => _CreateCampaignFormState();
}

class _CreateCampaignFormState extends State<CreateCampaignForm> {
  final _titleController = TextEditingController();
  String? _selectedAudience;
  String? _selectedInbox;
  String? _selectedTemplate;
  DateTime? _scheduledTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      final initialAudience = widget.initialData!['audience'];
      if (["Cold", "Warm", "Hot", "Booked", "Completed"].contains(initialAudience)) {
        _selectedAudience = initialAudience;
      }
      _selectedInbox = widget.initialData!['inbox'];
      _selectedTemplate = widget.initialData!['template'];
      // Handle date if present
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
            decoration: _inputDecoration("Please enter the title of campaign"),
          ),
          const SizedBox(height: 20),
          _buildLabel("Select Inbox"),
          DropdownButtonFormField<String>(
            value: _selectedInbox,
            items: ["Select Inbox", "Inbox 1", "Inbox 2"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: widget.isReadOnly ? null : (v) => setState(() => _selectedInbox = v),
            decoration: _inputDecoration("Select Inbox"),
          ),
          // const SizedBox(height: 20),
          const SizedBox(height: 20),
          _buildLabel("Audience"),
          DropdownButtonFormField<String>(
            value: _selectedAudience,
            items: ["Cold", "Warm", "Hot", "Booked", "Completed"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: widget.isReadOnly ? null : (v) => setState(() => _selectedAudience = v),
            decoration: _inputDecoration("Select the customer labels"),
          ),
          const SizedBox(height: 20),
          _buildLabel("Scheduled time"),
          TextFormField(
            readOnly: true,
            decoration: _inputDecoration("dd/mm/yyyy, --:-- --").copyWith(
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            onTap: widget.isReadOnly ? null : () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _scheduledTime = date);
              }
            },
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
                    onPressed: widget.onCreate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(widget.initialData != null ? "Update" : "Create", style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark 
          ? AppColor.backgroundDark.withValues(alpha: 0.5) 
          : Colors.grey.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerTheme.color ?? AppColor.borderLight, width: 1),
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
