import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/AiAgent/bloc/agent_management_bloc.dart';
import 'package:roberto/features/AiAgent/bloc/agent_management_event.dart';
import 'package:roberto/features/AiAgent/bloc/agent_management_state.dart';
import 'package:roberto/features/AiAgent/data/models/agent_model.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainingDataView extends StatefulWidget {
  final String businessId;
  const TrainingDataView({super.key, required this.businessId});

  @override
  State<TrainingDataView> createState() => _TrainingDataViewState();
}

class _TrainingDataViewState extends State<TrainingDataView> {
  // Newly picked local files (before upload)
  PlatformFile? _newRulesFile;
  PlatformFile? _newProductFile;

  bool _isSaving = false;

  Future<void> _pickFile(String slot) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result != null) {
      setState(() {
        if (slot == 'rules') {
          _newRulesFile = result.files.single;
        } else {
          _newProductFile = result.files.single;
        }
      });
    }
  }

  Future<void> _saveChanges(AgentModel agent) async {
    final hasRules = _newRulesFile != null;
    final hasProduct = _newProductFile != null;

    if (!hasRules && !hasProduct) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No new files selected to upload')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (hasRules) {
        // Update rules file (PDF) — uses UpdateAgentRequested
        context.read<AgentManagementBloc>().add(
          UpdateAgentRequested(
            id: agent.id,
            businessId: agent.businessId,
            agentName: agent.metadata?.agentName ?? '',
            fileBytes: _newRulesFile!.bytes?.toList(),
            fileName: _newRulesFile!.name,
          ),
        );
      }

      if (hasProduct) {
        // Update product file (Excel) — uses UpdateProductFileRequested
        context.read<AgentManagementBloc>().add(
          UpdateProductFileRequested(
            id: agent.id,
            vapiId: agent.vapiId ?? '',
            fileBytes: _newProductFile!.bytes?.toList(),
            fileName: _newProductFile!.name,
          ),
        );
      }

      setState(() {
        _newRulesFile = null;
        _newProductFile = null;
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AgentManagementBloc, AgentManagementState>(
      listener: (context, state) {
        if (state is AgentManagementOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          // Refresh agent list to get new URLs
          context.read<AgentManagementBloc>().add(const FetchAgentsRequested());
        } else if (state is AgentManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is AgentManagementLoading;

        // Find the agent for this business
        AgentModel? agent;
        if (state is AgentManagementLoaded) {
          agent = state.agents.cast<AgentModel?>().firstWhere(
            (a) => a?.businessId == widget.businessId,
            orElse: () => null,
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerTheme.color ?? Colors.grey.shade200,
            ),
          ),
          child: isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                )
              : agent == null
                  ? _buildEmpty(theme)
                  : _buildContent(theme, agent),
        );
      },
    );
  }

  Widget _buildContent(ThemeData theme, AgentModel agent) {
    final bool hasChanges = _newRulesFile != null || _newProductFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Data Files',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View and update files used to train the AI agent',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            if (hasChanges)
              ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _saveChanges(agent),
                icon: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined, size: 16),
                label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),

        // Policies / Rules File (PDF)
        _buildFileSlot(
          theme: theme,
          label: 'Policies & Rules File',
          fileTypeHint: 'PDF document',
          icon: Icons.picture_as_pdf_outlined,
          iconColor: Colors.red.shade600,
          serverUrl: agent.rulesFile,
          newFile: _newRulesFile,
          onPick: () => _pickFile('rules'),
          onClearNew: () => setState(() => _newRulesFile = null),
        ),

        const SizedBox(height: 20),

        // Product File (Excel)
        _buildFileSlot(
          theme: theme,
          label: 'Product Information File',
          fileTypeHint: 'Excel / spreadsheet',
          icon: Icons.table_chart_outlined,
          iconColor: Colors.green.shade600,
          serverUrl: agent.productFile,
          newFile: _newProductFile,
          onPick: () => _pickFile('product'),
          onClearNew: () => setState(() => _newProductFile = null),
        ),
      ],
    );
  }

  Widget _buildFileSlot({
    required ThemeData theme,
    required String label,
    required String fileTypeHint,
    required IconData icon,
    required Color iconColor,
    required String? serverUrl,
    required PlatformFile? newFile,
    required VoidCallback onPick,
    required VoidCallback onClearNew,
  }) {
    final hasServer = serverUrl != null && serverUrl.isNotEmpty;
    final hasNew = newFile != null;
    final fileName = hasNew
        ? newFile.name
        : hasServer
            ? _extractFileName(serverUrl)
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
          // File chip
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
                            ? '📎 New file — not yet uploaded'
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
                    onPressed: () => _openUrl(serverUrl),
                    icon: Icon(Icons.open_in_new, size: 13, color: iconColor),
                    label: Text(
                      'View',
                      style: TextStyle(
                          fontSize: 12,
                          color: iconColor,
                          fontWeight: FontWeight.w500),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: iconColor,
                      side: BorderSide(color: iconColor.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
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
                        fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.4)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
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
                        minWidth: 28, minHeight: 28),
                  ),
                ],
              ],
            ),
          )
        else
          // Upload drop zone
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
                color: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.3),
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

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined, size: 56, color: theme.hintColor),
            const SizedBox(height: 14),
            Text(
              'No training data found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No AI agent has been created for this business yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) return uri.pathSegments.last;
    } catch (_) {}
    return url;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open file URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
