import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_bloc.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_event.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_state.dart';
import 'package:roberto/features/AiAgent/data/models/agent_training_model.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainingDataView extends StatefulWidget {
  final String businessId;
  const TrainingDataView({super.key, required this.businessId});

  @override
  State<TrainingDataView> createState() => _TrainingDataViewState();
}

class _TrainingDataViewState extends State<TrainingDataView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessInfoController = TextEditingController();

  String? _trainingId;

  // New selected local files
  PlatformFile? _newProductFile;
  PlatformFile? _newPoliciesFile;
  PlatformFile? _newFaqFile;

  // URLs of files stored on the server
  String? _serverProductUrl;
  String? _serverPoliciesUrl;
  String? _serverFaqUrl;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final state = context.read<AgentTrainingBloc>().state;
    if (state is SingleAgentTrainingLoaded) {
      _populateFromTraining(state.training);
    }
  }

  void _populateFromTraining(AgentTraining training) {
    _businessInfoController.text = training.businessInformation ?? '';
    _trainingId = training.id;

    _serverProductUrl = _extractUrl(training.productInformation);
    _serverPoliciesUrl = _extractUrl(training.policiesGuidelines);
    _serverFaqUrl = _extractUrl(training.faq);
  }

  String? _extractUrl(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return value;
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map) {
        return first['url']?.toString() ?? first['path']?.toString();
      }
    }
    if (value is Map) {
      return value['url']?.toString() ?? value['path']?.toString();
    }
    return null;
  }

  String _getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) return uri.pathSegments.last;
    } catch (_) {}
    return url;
  }

  Future<void> _pickFile(String slot) async {
    List<String> allowedExtensions;
    if (slot == 'product') {
      allowedExtensions = ['xlsx', 'xls'];
    } else {
      allowedExtensions = ['pdf'];
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      
      if ((slot == 'policies' || slot == 'faq') && file.size > 3 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("File size exceeds 3MB limit. Please upload a smaller file."),
            backgroundColor: Colors.red,
          )
        );
        return;
      }

      setState(() {
        if (slot == 'product') {
          _newProductFile = file;
        } else if (slot == 'policies') {
          _newPoliciesFile = file;
        } else if (slot == 'faq') {
          _newFaqFile = file;
        }
      });
    }
  }

  Future<void> _viewFile(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the file URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveTrainingData() {
    if (!_formKey.currentState!.validate()) return;

    final businessInfo = _businessInfoController.text.trim();

    // Validations: businessInfo, productInformation, policiesGuidelines are required.
    // faq is optional.
    final hasProduct = _newProductFile != null || (_serverProductUrl != null && _serverProductUrl!.isNotEmpty);
    final hasPolicies = _newPoliciesFile != null || (_serverPoliciesUrl != null && _serverPoliciesUrl!.isNotEmpty);

    if (!hasProduct) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product Information file (Excel) is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!hasPolicies) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Policies & Guidelines file (PDF) is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_trainingId != null) {
      // PATCH / Update
      context.read<AgentTrainingBloc>().add(
        UpdateAgentTrainingRequested(
          id: _trainingId!,
          businessInformation: businessInfo,
          productInformationFile: _newProductFile,
          policiesGuidelinesFile: _newPoliciesFile,
          faqFile: _newFaqFile,
        ),
      );
    } else {
      // POST / Create
      context.read<AgentTrainingBloc>().add(
        CreateAgentTrainingRequested(
          businessId: widget.businessId,
          systemPrompt: '', // Initial prompt can be empty, updated in Prompt tab
          businessInformation: businessInfo,
          productInformationFile: _newProductFile,
          policiesGuidelinesFile: _newPoliciesFile,
          faqFile: _newFaqFile,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AgentTrainingBloc, AgentTrainingState>(
      listener: (context, state) {
        if (state is SingleAgentTrainingLoaded) {
          setState(() {
            _populateFromTraining(state.training);
            _newProductFile = null;
            _newPoliciesFile = null;
            _newFaqFile = null;
          });
        } else if (state is AgentTrainingOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AgentTrainingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AgentTrainingLoading;

        return Form(
          key: _formKey,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerTheme.color ?? Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Business Training Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Provide business information and documents to train the AI agent.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 24),

                // Business Information Text Field
                Text(
                  'Business Information (Max 4000 words) *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextfield(
                  hintText: "Enter business name, location, working hours, and services details...",
                  controller: _businessInfoController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business information is required';
                    }
                    final wordCount = value.trim().split(RegExp(r'\s+')).length;
                    if (wordCount > 4000) {
                      return 'Business information cannot exceed 4000 words';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Product Information Upload (Excel required)
                _buildFileSlot(
                  label: 'Product Information (Excel) *',
                  fileTypeHint: 'Only .xlsx or .xls files are allowed',
                  icon: Icons.table_chart_outlined,
                  iconColor: Colors.green.shade600,
                  serverUrl: _serverProductUrl,
                  newFile: _newProductFile,
                  onPick: () => _pickFile('product'),
                  onClearNew: () => setState(() => _newProductFile = null),
                ),
                const SizedBox(height: 20),

                // Policies & Guidelines Upload (PDF required)
                _buildFileSlot(
                  label: 'Policies & Guidelines (PDF, Max 3MB) *',
                  fileTypeHint: 'Only .pdf files are allowed',
                  icon: Icons.picture_as_pdf_outlined,
                  iconColor: Colors.red.shade600,
                  serverUrl: _serverPoliciesUrl,
                  newFile: _newPoliciesFile,
                  onPick: () => _pickFile('policies'),
                  onClearNew: () => setState(() => _newPoliciesFile = null),
                ),
                const SizedBox(height: 20),

                // FAQ Upload (PDF optional)
                _buildFileSlot(
                  label: 'Common FAQs (PDF, Optional, Max 3MB)',
                  fileTypeHint: 'Only .pdf files are allowed',
                  icon: Icons.question_answer_outlined,
                  iconColor: Colors.blue.shade600,
                  serverUrl: _serverFaqUrl,
                  newFile: _newFaqFile,
                  onPick: () => _pickFile('faq'),
                  onClearNew: () => setState(() => _newFaqFile = null),
                ),
                const SizedBox(height: 28),

                // Save button
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _saveTrainingData,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    isLoading ? 'Saving...' : 'Save Training Data',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileSlot({
    required String label,
    required String fileTypeHint,
    required IconData icon,
    required Color iconColor,
    required String? serverUrl,
    required PlatformFile? newFile,
    required VoidCallback onPick,
    required VoidCallback onClearNew,
  }) {
    final theme = Theme.of(context);
    final hasServer = serverUrl != null && serverUrl.isNotEmpty;
    final hasNew = newFile != null;
    final fileName = hasNew
        ? newFile.name
        : hasServer
            ? _getFileName(serverUrl)
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        if (hasNew || hasServer)
          // File display card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: hasNew
                  ? iconColor.withOpacity(0.06)
                  : iconColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasNew
                    ? iconColor.withOpacity(0.5)
                    : iconColor.withOpacity(0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasNew
                            ? '📎 New file selected'
                            : '✅ Uploaded to server',
                        style: TextStyle(
                          fontSize: 11,
                          color: hasNew ? iconColor : Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // View server file button
                if (hasServer && !hasNew)
                  OutlinedButton.icon(
                    onPressed: () => _viewFile(serverUrl),
                    icon: Icon(Icons.open_in_new, size: 13, color: iconColor),
                    label: Text(
                      'View',
                      style: TextStyle(
                        fontSize: 12,
                        color: iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: iconColor,
                      side: BorderSide(color: iconColor.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),

                const SizedBox(width: 6),

                // Replace button
                OutlinedButton.icon(
                  onPressed: onPick,
                  icon: Icon(Icons.swap_horiz_outlined,
                      size: 13, color: theme.colorScheme.primary),
                  label: Text(
                    'Replace',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),

                // Clear new file (if pending)
                if (hasNew) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Cancel',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClearNew,
                    color: theme.hintColor,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          // Upload click zone
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.4),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(10),
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      color: theme.hintColor, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    'No file uploaded — tap to browse',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fileTypeHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
