import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/AiAgent/bloc/agent_management_bloc.dart';
import 'package:roberto/features/AiAgent/bloc/agent_management_event.dart';
import 'package:roberto/features/AiAgent/bloc/agent_management_state.dart';
import 'package:roberto/features/AiAgent/data/models/agent_model.dart';
import 'package:roberto/features/TenantManagement/bloc/tenant_bloc.dart';
import 'package:roberto/features/TenantManagement/bloc/tenant_event.dart';
import 'package:roberto/features/TenantManagement/bloc/tenant_state.dart';
import 'package:roberto/features/TenantManagement/data/models/tenant_model.dart';

class AgentManagementScreen extends StatefulWidget {
  final String? businessId;
  const AgentManagementScreen({super.key, this.businessId});

  @override
  State<AgentManagementScreen> createState() => _AgentManagementScreenState();
}

class _AgentManagementScreenState extends State<AgentManagementScreen> {
  TenantBusiness? _selectedBusiness;
  TenantBranch? _selectedBranch;

  @override
  void initState() {
    super.initState();
    // Load agents and tenants/businesses list globally
    context.read<AgentManagementBloc>().add(const FetchAgentsRequested());
    context.read<TenantBloc>().add(const FetchTenantsRequested());
  }

  void _onBusinessChanged(TenantBusiness? business) {
    setState(() {
      _selectedBusiness = business;
      if (business != null && business.branches.isNotEmpty) {
        _selectedBranch = business.branches.first;
      } else {
        _selectedBranch = null;
      }
    });
  }

  void _onBranchChanged(TenantBranch? branch) {
    setState(() {
      _selectedBranch = branch;
    });
  }

  Future<void> _openRulesUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the rules file URL.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AgentManagementBloc, AgentManagementState>(
      listener: (context, state) {
        if (state is AgentManagementOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AgentManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Agent Management',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 600
                            ? 24
                            : 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Deploy, configure and manage AI voice assistants for tenants',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Business & Tenant Selector Card
          _buildBusinessSelectorCard(theme, isDark),
          const SizedBox(height: 28),

          if (_selectedBusiness == null)
            _buildNoBusinessSelectedState(theme)
          else if (_selectedBranch == null)
            _buildNoBranchSelectedState(theme)
          else
            _buildAgentContent(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildBusinessSelectorCard(ThemeData theme, bool isDark) {
    return BlocBuilder<TenantBloc, TenantState>(
      builder: (context, state) {
        if (state is TenantLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerTheme.color ?? const Color(0xffEEEEEE),
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is TenantError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerTheme.color ?? const Color(0xffEEEEEE),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Failed to load businesses: ${state.message}',
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.read<TenantBloc>().add(
                      const FetchTenantsRequested(),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        List<TenantBusiness> businesses = [];
        if (state is TenantLoaded) {
          businesses = state.tenantResponse.businesses;
          if (businesses.isNotEmpty) {
            if (_selectedBusiness == null) {
              if (widget.businessId != null) {
                _selectedBusiness = businesses.firstWhere(
                  (b) => b.id == widget.businessId,
                  orElse: () => businesses.first,
                );
              } else {
                _selectedBusiness = businesses.first;
              }
              if (_selectedBusiness != null &&
                  _selectedBusiness!.branches.isNotEmpty) {
                _selectedBranch = _selectedBusiness!.branches.first;
              }
            } else {
              // Resolve _selectedBusiness to the new instance in the list by matching ID
              _selectedBusiness = businesses.firstWhere(
                (b) => b.id == _selectedBusiness!.id,
                orElse: () => businesses.first,
              );
              if (_selectedBranch != null && _selectedBusiness != null) {
                TenantBranch? foundBranch;
                for (final branch in _selectedBusiness!.branches) {
                  if (branch.id == _selectedBranch!.id) {
                    foundBranch = branch;
                    break;
                  }
                }
                if (foundBranch != null) {
                  _selectedBranch = foundBranch;
                } else {
                  _selectedBranch = _selectedBusiness!.branches.isNotEmpty
                      ? _selectedBusiness!.branches.first
                      : null;
                }
              }
            }
          } else {
            _selectedBusiness = null;
            _selectedBranch = null;
          }
        }

        final bool hasBranches =
            _selectedBusiness != null && _selectedBusiness!.branches.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerTheme.color ?? const Color(0xffEEEEEE),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;

                  final businessDropdown = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Business Owner',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      businesses.isEmpty
                          ? const Text('No active businesses found.')
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      theme.dividerTheme.color ??
                                      const Color(0xffCCCCCC),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<TenantBusiness>(
                                  value: _selectedBusiness,
                                  isExpanded: true,
                                  dropdownColor: theme.cardTheme.color,
                                  items: businesses.map((b) {
                                    return DropdownMenuItem<TenantBusiness>(
                                      value: b,
                                      child: Text(
                                        b.name,
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _onBusinessChanged,
                                ),
                              ),
                            ),
                    ],
                  );

                  final branchDropdown = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Tenant (Branch)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _selectedBusiness == null
                          ? const Text('Choose a business first.')
                          : !hasBranches
                          ? Text(
                              'No branches/tenants found.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      theme.dividerTheme.color ??
                                      const Color(0xffCCCCCC),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<TenantBranch>(
                                  value: _selectedBranch,
                                  isExpanded: true,
                                  dropdownColor: theme.cardTheme.color,
                                  items: _selectedBusiness!.branches.map((br) {
                                    return DropdownMenuItem<TenantBranch>(
                                      value: br,
                                      child: Text(
                                        br.name,
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _onBranchChanged,
                                ),
                              ),
                            ),
                    ],
                  );

                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: businessDropdown),
                            const SizedBox(width: 16),
                            Expanded(child: branchDropdown),
                          ],
                        )
                      : Column(
                          children: [
                            businessDropdown,
                            const SizedBox(height: 16),
                            branchDropdown,
                          ],
                        );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoBusinessSelectedState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Business Selected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please select a business to manage its AI voice agents.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBranchSelectedState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Tenant (Branch) Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Selected business has no branches/tenants configured.'),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentContent(ThemeData theme, bool isDark) {
    return BlocBuilder<AgentManagementBloc, AgentManagementState>(
      builder: (context, state) {
        if (state is AgentManagementLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        List<AgentModel> businessAgents = [];
        if (state is AgentManagementLoaded &&
            _selectedBusiness != null &&
            _selectedBranch != null) {
          businessAgents = state.agents
              .where(
                (a) =>
                    a.businessId == _selectedBusiness!.id &&
                    a.branchId == _selectedBranch!.id,
              )
              .toList();
        }

        // Stats section
        final int totalAgents = businessAgents.length;
        final int rulesFilesCount = businessAgents
            .where((a) => a.rulesFile != null && a.rulesFile!.isNotEmpty)
            .length;

        final bool isWide = MediaQuery.of(context).size.width > 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            if (isWide)
              Row(
                children: [
                  Expanded(
                    child: _buildStatMiniCard(
                      theme: theme,
                      title: 'Total Voice Agents',
                      value: '$totalAgents',
                      icon: Icons.record_voice_over_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatMiniCard(
                      theme: theme,
                      title: 'Rules Configured',
                      value: '$rulesFilesCount',
                      icon: Icons.picture_as_pdf_outlined,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildStatMiniCard(
                    theme: theme,
                    title: 'Total Voice Agents',
                    value: '$totalAgents',
                    icon: Icons.record_voice_over_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildStatMiniCard(
                    theme: theme,
                    title: 'Rules Configured',
                    value: '$rulesFilesCount',
                    icon: Icons.picture_as_pdf_outlined,
                  ),
                ],
              ),
            const SizedBox(height: 28),

            // Header for agent listing
            if (isWide)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI Voice Assistants',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddOrEditAgentDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Deploy Voice Agent',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Voice Assistants',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddOrEditAgentDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Deploy Voice Agent',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            businessAgents.isEmpty
                ? _buildEmptyAgentsPlaceholder(theme)
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: businessAgents.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final agent = businessAgents[index];
                      return _buildAgentCard(context, theme, agent, isDark);
                    },
                  ),
          ],
        );
      },
    );
  }

  Widget _buildStatMiniCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerTheme.color ?? const Color(0xffEEEEEE),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColor.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAgentsPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerTheme.color ?? const Color(0xffEEEEEE),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 64,
            color: AppColor.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Voice Agents Deployed',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a voice assistant for this tenant (branch) and configure call guidelines.',
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _showAddOrEditAgentDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Deploy First Agent'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.primary,
              side: const BorderSide(color: AppColor.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(
    BuildContext context,
    ThemeData theme,
    AgentModel agent,
    bool isDark,
  ) {
    final metadata = agent.metadata;
    final agentName = metadata?.agentName ?? 'Unknown Name';
    final assistantId = agent.vapiId ?? 'Not Configured';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerTheme.color ?? const Color(0xffEEEEEE),
        ),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  theme.cardTheme.color!,
                  theme.cardTheme.color!.withOpacity(0.8),
                ]
              : [Colors.white, theme.colorScheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agentName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${agent.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () => _showDeleteConfirmation(context, agent),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAgentProperty(
                      theme,
                      'Tenant (Branch) ID',
                      agent.branchId,
                    ),
                    const SizedBox(height: 12),
                    _buildAgentProperty(
                      theme,
                      'Assistant ID (Vapi)',
                      assistantId,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAgentProperty(
                      theme,
                      'Deployed On',
                      agent.createdAt != null
                          ? agent.createdAt!.substring(0, 10)
                          : 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildRulesFileButton(theme, agent.rulesFile),
                    const SizedBox(height: 12),
                    _buildProductFileButton(theme, agent.productFile),
                  ],
                ),
              ),
            ],
          ),
          if (agent.twilioNumber != null && agent.twilioNumber!.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildAgentProperty(
                    theme,
                    'Twilio Number',
                    agent.twilioNumber!,
                  ),
                ),
                Expanded(
                  child: _buildAgentProperty(
                    theme,
                    'Transfer Number',
                    (agent.transferNumber != null &&
                            agent.transferNumber!.isNotEmpty)
                        ? agent.transferNumber!
                        : 'N/A',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Update Excel (productFile) button
              ElevatedButton.icon(
                onPressed: () => _showUpdateProductFileDialog(context, agent),
                icon: const Icon(Icons.table_chart_outlined, size: 16),
                label: const Text(
                  'Update Excel',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 10),
              // Add/Update Twilio Number button
              if (agent.metadata?.twilioResponse != null)
                ElevatedButton.icon(
                  onPressed: () => _showTwilioDetailsDialog(context, agent),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text(
                    'View Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _showTwilioSetupDialog(context, agent),
                  icon: const Icon(Icons.phone_in_talk_outlined, size: 16),
                  label: const Text(
                    'Add Twilio Number',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentProperty(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRulesFileButton(ThemeData theme, String? rulesUrl) {
    final hasRules = rulesUrl != null && rulesUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Rules File',
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        hasRules
            ? InkWell(
                onTap: () => _openRulesUrl(rulesUrl),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      size: 16,
                      color: AppColor.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'View Rules PDF',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'No rules uploaded',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildProductFileButton(ThemeData theme, String? productFileUrl) {
    final hasFile = productFileUrl != null && productFileUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product File (Excel)',
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        hasFile
            ? InkWell(
                onTap: () => _openRulesUrl(productFileUrl),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.table_chart_outlined,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'View Product Excel',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'No product file uploaded',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ],
    );
  }


  void _showDeleteConfirmation(BuildContext context, AgentModel agent) {
    if (agent.metadata?.twilioResponse != null) {
      showDialog(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          return AlertDialog(
            backgroundColor: theme.cardTheme.color,
            title: const Text('Cannot Delete Agent'),
            content: const Text(
              'This agent currently has a Twilio number configured. You must first view details and delete the Twilio number before deleting the agent.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          title: const Text('Delete Voice Agent'),
          content: const Text(
            'Are you sure you want to delete this voice agent? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AgentManagementBloc>().add(
                  DeleteAgentRequested(id: agent.id),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddOrEditAgentDialog(BuildContext context, {AgentModel? agent}) {
    final isEdit = agent != null;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return _AgentFormDialog(
          theme: theme,
          isEdit: isEdit,
          agent: agent,
          selectedBusiness: _selectedBusiness!,
          selectedBranch: _selectedBranch!,
          blocContext: context,
        );
      },
    );
  }

  void _showTwilioDetailsDialog(BuildContext context, AgentModel agent) {
    final twilioResponse = agent.metadata?.twilioResponse ?? {};
    final theme = Theme.of(context);
    final phoneNumber = twilioResponse['phoneNumber'] as Map<String, dynamic>? ?? {};
    final tool = twilioResponse['tool'] as Map<String, dynamic>? ?? {};
    final destinations = tool['destinations'] as List<dynamic>? ?? [];
    final transferNumber = destinations.isNotEmpty ? destinations.first['number']?.toString() ?? 'N/A' : 'N/A';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Twilio Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'Delete Twilio Configuration',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (confirmContext) => AlertDialog(
                                backgroundColor: theme.cardColor,
                                title: const Text('Delete Twilio Configuration'),
                                content: const Text('Are you sure you want to delete this Twilio configuration?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(confirmContext),
                                    child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () {
                                      final phoneNumberId = phoneNumber['id']?.toString() ?? '';
                                      final transferToolId = tool['id']?.toString() ?? '';
                                      final assistantId = agent.vapiId ?? '';
                                      
                                      context.read<AgentManagementBloc>().add(
                                        TeardownTwilioRequested(
                                          phoneNumberId: phoneNumberId,
                                          transferToolId: transferToolId,
                                          assistantId: assistantId,
                                        ),
                                      );
                                      Navigator.pop(confirmContext);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildAgentProperty(theme, 'Twilio Name', phoneNumber['name']?.toString() ?? 'N/A'),
                const SizedBox(height: 16),
                _buildAgentProperty(theme, 'Twilio Number', phoneNumber['number']?.toString() ?? 'N/A'),
                const SizedBox(height: 16),
                _buildAgentProperty(theme, 'Status', phoneNumber['status']?.toString() ?? 'N/A'),
                const SizedBox(height: 16),
                _buildAgentProperty(theme, 'Account SID', phoneNumber['twilioAccountSid']?.toString() ?? 'N/A'),
                const SizedBox(height: 16),
                _buildAgentProperty(theme, 'Transfer Number', transferNumber),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTwilioSetupDialog(BuildContext context, AgentModel agent) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return _TwilioSetupDialog(
          theme: theme,
          agent: agent,
          blocContext: context,
        );
      },
    );
  }

  void _showUpdateProductFileDialog(BuildContext context, AgentModel agent) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return _UpdateProductFileDialog(
          theme: theme,
          agent: agent,
          blocContext: context,
        );
      },
    );
  }
}

class _AgentFormDialog extends StatefulWidget {
  final ThemeData theme;
  final bool isEdit;
  final AgentModel? agent;
  final TenantBusiness selectedBusiness;
  final TenantBranch selectedBranch;
  final BuildContext blocContext;

  const _AgentFormDialog({
    required this.theme,
    required this.isEdit,
    this.agent,
    required this.selectedBusiness,
    required this.selectedBranch,
    required this.blocContext,
  });

  @override
  State<_AgentFormDialog> createState() => _AgentFormDialogState();
}

class _AgentFormDialogState extends State<_AgentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  PlatformFile? _pickedFile;         // rules_file (PDF/Word)
  PlatformFile? _pickedProductFile;  // productFile (Excel)

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.isEdit ? (widget.agent?.metadata?.agentName ?? '') : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      if (result.files.single.size > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("File size exceeds 5MB limit. Please upload a smaller file."),
            backgroundColor: Colors.red,
          )
        );
        return;
      }
      setState(() => _pickedFile = result.files.single);
    }
  }

  Future<void> _pickProductFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      if (result.files.single.size > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("File size exceeds 5MB limit. Please upload a smaller file."),
            backgroundColor: Colors.red,
          )
        );
        return;
      }
      setState(() => _pickedProductFile = result.files.single);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final String agentName = _nameController.text.trim();

    if (widget.isEdit) {
      widget.blocContext.read<AgentManagementBloc>().add(
        UpdateAgentRequested(
          id: widget.agent!.id,
          businessId: widget.selectedBusiness.id,
          agentName: agentName,
          filePath: kIsWeb ? null : _pickedFile?.path,
          fileBytes: _pickedFile?.bytes,
          fileName: _pickedFile?.name,
        ),
      );
    } else {
      widget.blocContext.read<AgentManagementBloc>().add(
        CreateAgentRequested(
          businessId: widget.selectedBusiness.id,
          agentName: agentName,
          branchId: widget.selectedBranch.id,
          filePath: kIsWeb ? null : _pickedFile?.path,
          fileBytes: _pickedFile?.bytes,
          fileName: _pickedFile?.name,
          productFilePath: kIsWeb ? null : _pickedProductFile?.path,
          productFileBytes: _pickedProductFile?.bytes,
          productFileName: _pickedProductFile?.name,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width < 600
            ? MediaQuery.of(context).size.width * 0.9
            : 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isEdit
                          ? 'Configure Voice Agent'
                          : 'Deploy Voice Agent',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure caller settings and rules files for this business.',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.theme.textTheme.bodySmall?.color,
                  ),
                ),
                const Divider(height: 32),

                // Agent Name
                Text(
                  'Agent Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Salman Education 1.0.0',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the agent name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Selected Tenant (Branch) read-only info
                Text(
                  'Tenant (Branch Location)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.theme.disabledColor.withOpacity(0.05),
                    border: Border.all(
                      color:
                          widget.theme.dividerTheme.color ??
                          const Color(0xffCCCCCC),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.selectedBranch.name,
                    style: TextStyle(
                      color: widget.theme.textTheme.bodyMedium?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // PDF Upload Section (rules_file)
                Text(
                  widget.isEdit
                      ? 'Update Call Rules (PDF/Word) - Max 5MB'
                      : 'Upload Call Rules (PDF/Word) - Max 5MB',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.primary),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColor.primary.withOpacity(0.02),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, color: AppColor.primary, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          _pickedFile != null
                              ? 'Selected: ${_pickedFile!.name}'
                              : 'Select call rules file (PDF/Word)',
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Excel Upload Section (productFile) — only on Create
                if (!widget.isEdit) ...[
                  Text(
                    'Upload Product Data (Excel) - Max 5MB',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickProductFile,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green.shade600),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green.withOpacity(0.02),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.table_chart_outlined, color: Colors.green.shade600, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            _pickedProductFile != null
                                ? 'Selected: ${_pickedProductFile!.name}'
                                : 'Select product data file (Excel / CSV)',
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.theme.textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // Submit Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: widget.theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.isEdit ? 'Save Changes' : 'Deploy Agent',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TwilioSetupDialog extends StatefulWidget {
  final ThemeData theme;
  final AgentModel agent;
  final BuildContext blocContext;

  const _TwilioSetupDialog({
    required this.theme,
    required this.agent,
    required this.blocContext,
  });

  @override
  State<_TwilioSetupDialog> createState() => _TwilioSetupDialogState();
}

class _TwilioSetupDialogState extends State<_TwilioSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sidController = TextEditingController();
  final _tokenController = TextEditingController();
  final _numberController = TextEditingController();
  final _transferController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load pre-existing configuration values if they exist
    _sidController.text = widget.agent.twilioSid ?? '';
    _tokenController.text = widget.agent.twilioAuthToken ?? '';
    _numberController.text = widget.agent.twilioNumber ?? '';
    _transferController.text = widget.agent.transferNumber ?? '';
  }

  @override
  void dispose() {
    _sidController.dispose();
    _tokenController.dispose();
    _numberController.dispose();
    _transferController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.blocContext.read<AgentManagementBloc>().add(
      SetupTwilioRequested(
        twilioSid: _sidController.text.trim(),
        twilioAuthToken: _tokenController.text.trim(),
        twilioNumber: _numberController.text.trim(),
        transferNumber: _transferController.text.trim(),
        assistantId: widget.agent.vapiId ?? '',
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText, bool enabled) {
    final theme = widget.theme;
    final isDark = theme.brightness == Brightness.dark;
    final baseBorderColor =
        theme.dividerTheme.color ??
        (isDark ? Colors.grey.shade800 : Colors.grey.shade400);

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabled: enabled,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: baseBorderColor.withOpacity(0.4)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: baseBorderColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assistantId = widget.agent.vapiId ?? 'Not Configured';
    final isDark = widget.theme.brightness == Brightness.dark;
    final dialogBorderColor =
        widget.theme.dividerTheme.color ??
        (isDark ? Colors.grey.shade800 : Colors.grey.shade300);

    return Dialog(
      backgroundColor: widget.theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: dialogBorderColor.withOpacity(0.6)),
      ),
      child: BlocConsumer<AgentManagementBloc, AgentManagementState>(
        bloc: widget.blocContext.read<AgentManagementBloc>(),
        listener: (context, state) {
          if (state is AgentManagementOperationSuccess &&
              state.message.contains("Twilio")) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is AgentManagementLoading;
          final errorMessage = state is AgentManagementError
              ? state.message
              : null;

          return Container(
            width: MediaQuery.of(context).size.width < 600
                ? MediaQuery.of(context).size.width * 0.9
                : 500,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Configure Twilio Number',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.theme.colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Associate a Twilio phone number with this voice agent.',
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.theme.textTheme.bodySmall?.color,
                      ),
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Divider(height: 32),

                    // Twilio Account SID
                    Text(
                      'Twilio Account SID',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _sidController,
                      enabled: !isLoading,
                      decoration: _buildInputDecoration(
                        'Enter Twilio Account SID',
                        !isLoading,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Account SID is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Twilio Auth Token
                    Text(
                      'Twilio Auth Token',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tokenController,
                      obscureText: true,
                      enabled: !isLoading,
                      decoration: _buildInputDecoration(
                        'Enter Twilio Auth Token',
                        !isLoading,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Auth Token is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Twilio Number
                    Text(
                      'Twilio Number (e.g. +1XXXXXXXXXX)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _numberController,
                      enabled: !isLoading,
                      decoration: _buildInputDecoration(
                        '+1XXXXXXXXXX',
                        !isLoading,
                      ),
                      validator: (value) {
                        final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
                        if (value == null || value.trim().isEmpty) {
                          return 'Twilio number is required';
                        } else if (!phoneRegex.hasMatch(value.trim())) {
                          return 'Enter a valid E.164 number (e.g. +1XXXXXXXXXX)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Transfer Number
                    Text(
                      'Transfer Number (e.g. +1XXXXXXXXXX)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _transferController,
                      enabled: !isLoading,
                      decoration: _buildInputDecoration(
                        '+1XXXXXXXXXX',
                        !isLoading,
                      ),
                      validator: (value) {
                        final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
                        if (value == null || value.trim().isEmpty) {
                          return 'Transfer number is required';
                        } else if (!phoneRegex.hasMatch(value.trim())) {
                          return 'Enter a valid E.164 number (e.g. +1XXXXXXXXXX)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Assistant ID Info (Read Only)
                    Text(
                      'Vapi Assistant ID',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: widget.theme.disabledColor.withOpacity(0.05),
                        border: Border.all(
                          color: dialogBorderColor.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        assistantId,
                        style: TextStyle(
                          color: widget.theme.textTheme.bodyMedium?.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: widget.theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Setup Twilio'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UpdateProductFileDialog extends StatefulWidget {
  final ThemeData theme;
  final AgentModel agent;
  final BuildContext blocContext;

  const _UpdateProductFileDialog({
    required this.theme,
    required this.agent,
    required this.blocContext,
  });

  @override
  State<_UpdateProductFileDialog> createState() => _UpdateProductFileDialogState();
}

class _UpdateProductFileDialogState extends State<_UpdateProductFileDialog> {
  PlatformFile? _pickedProductFile;

  Future<void> _pickProductFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedProductFile = result.files.single);
    }
  }

  void _submit() {
    if (_pickedProductFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an Excel file first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.blocContext.read<AgentManagementBloc>().add(
      UpdateProductFileRequested(
        id: widget.agent.id,
        vapiId: widget.agent.vapiId ?? '',
        filePath: kIsWeb ? null : _pickedProductFile?.path,
        fileBytes: _pickedProductFile?.bytes,
        fileName: _pickedProductFile?.name,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width < 600
            ? MediaQuery.of(context).size.width * 0.9
            : 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Update Excel Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Upload new product data (Excel/CSV) for ${widget.agent.metadata?.agentName ?? 'this agent'}.',
              style: TextStyle(
                fontSize: 13,
                color: widget.theme.textTheme.bodySmall?.color,
              ),
            ),
            const Divider(height: 32),

            InkWell(
              onTap: _pickProductFile,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade600),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green.withOpacity(0.02),
                ),
                child: Column(
                  children: [
                    Icon(Icons.table_chart_outlined, color: Colors.green.shade600, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      _pickedProductFile != null
                          ? 'Selected: ${_pickedProductFile!.name}'
                          : 'Select new product data file (Excel / CSV)',
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: widget.theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _pickedProductFile == null ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Update Excel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
