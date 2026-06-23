import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/custom_search.dart';
import 'package:roberto/features/CRM/widget/custom_lead_row.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_headder.dart';
import 'package:roberto/common/custom_pagination.dart';
import 'package:roberto/features/CRM/bloc/crm_bloc.dart';
import 'package:roberto/features/CRM/bloc/crm_event.dart';
import 'package:roberto/features/CRM/bloc/crm_state.dart';
import 'package:roberto/features/CRM/data/models/crm_lead_model.dart';
import 'package:intl/intl.dart';
import 'package:roberto/common/user_role.dart';

class CustomCrm extends StatefulWidget {
  final Function(String)? onNavigate;
  final UserRole role;
  const CustomCrm({super.key, this.onNavigate, this.role = UserRole.businessOwner});

  @override
  State<CustomCrm> createState() => _CustomCrmState();
}

class _CustomCrmState extends State<CustomCrm> {
  String _selectedStatus = "All Status";
  int _currentPage = 1;
  static const int _itemsPerPage = 20;

  // Use a fixed branchId for the testing phase per business owner user requirement
  final String _testBranchId = '5feaac7b-c436-4ecb-8a12-9632e4090205';

  @override
  void initState() {
    super.initState();
    // Fetch initial leads
    context.read<CrmBloc>().add(FetchLeads(branchId: _testBranchId, role: widget.role));
  }

  Color _getTagColor(String? status) {
    if (status == null) return AppColor.greens;
    final lStatus = status.toLowerCase();
    if (lStatus.contains("cold")) return AppColor.deepgreen;
    if (lStatus.contains("warm")) return AppColor.greens;
    if (lStatus.contains("hot")) return AppColor.primary;
    if (lStatus.contains("book")) return AppColor.ma;
    return AppColor.greens;
  }

  String _getSocialIcon(String? source) {
    if (source == null) return 'assets/whatsapp.svg';
    final lSource = source.toLowerCase();
    if (lSource.contains('facebook')) return 'assets/facebook.svg';
    if (lSource.contains('insta')) return 'assets/instagram.svg';
    return 'assets/whatsapp.svg'; // fallback
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy h:mm a').format(dt.toLocal());
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    final theme = Theme.of(context);

    return BlocConsumer<CrmBloc, CrmState>(
      listener: (context, state) {
        if (state is CrmActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is CrmError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        List<CrmLeadModel> leads = [];
        bool isLoading = true;

        if (state is CrmLeadsLoaded) {
          leads = state.leads;
          isLoading = false;
        } else if (state is CrmError || state is CrmInitial) {
          isLoading = false;
        }

        final filteredLeads = _selectedStatus == "All Status"
            ? leads
            : leads.where((lead) {
                return (lead.status ?? '').toLowerCase() == _selectedStatus.toLowerCase();
              }).toList();

        final paginatedLeads = filteredLeads.sublist(
          (filteredLeads.isNotEmpty) ? (_currentPage - 1) * _itemsPerPage : 0,
          ((_currentPage * _itemsPerPage) > filteredLeads.length)
              ? filteredLeads.length
              : (_currentPage * _itemsPerPage),
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Side (Texts)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lead Pipeline",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Manage your leads efficiently",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right Side (Search + Status)
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Search
                              const CustomSearch(),

                              const SizedBox(width: 10),

                              // Status Button
                              _buildStatusButton(context),
                              const SizedBox(width: 10),
                              // Refresh
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  context.read<CrmBloc>().add(FetchLeads(branchId: _testBranchId, role: widget.role));
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lead Pipeline",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: CustomSearch()),
                            const SizedBox(width: 10),
                            _buildStatusButton(context),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () {
                                context.read<CrmBloc>().add(FetchLeads(branchId: _testBranchId, role: widget.role));
                              },
                            )
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: 26),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      if (isDesktop)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? theme.colorScheme.surface
                              : theme.colorScheme.secondary,
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 3,
                                child: CustomHeadder(label: 'Name'),
                              ),
                              Expanded(
                                flex: 3,
                                child: CustomHeadder(label: 'Contact'),
                              ),
                              Expanded(
                                flex: 2,
                                child: CustomHeadder(label: 'Source'),
                              ),
                              Expanded(
                                flex: 2,
                                child: CustomHeadder(label: 'Status'),
                              ),
                              Expanded(
                                flex: 2,
                                child: CustomHeadder(label: 'Last Contact'),
                              ),
                              Expanded(
                                flex: 1,
                                child: CustomHeadder(label: 'Actions'),
                              ),
                            ],
                          ),
                        ),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (paginatedLeads.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: Text("No leads found")),
                        )
                      else 
                        ...paginatedLeads.map((lead) => CustomLeadRow(
                              name: lead.name ?? 'Unknown',
                              email: lead.email ?? '',
                              phone: lead.phone ?? '',
                              socialText: lead.source ?? 'Unknown',
                              socialIcon: _getSocialIcon(lead.source),
                              tagText: lead.status ?? 'Warm',
                              tagColor: _getTagColor(lead.status),
                              time: _formatDate(lead.createdAt),
                              notes: lead.note,
                              onNavigate: widget.onNavigate,
                              fullLeadData: lead,
                              role: widget.role,
                            )),
                      if (filteredLeads.isNotEmpty && !isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomPagination(
                            totalItems: filteredLeads.length,
                            itemsPerPage: _itemsPerPage,
                            currentPage: _currentPage,
                            onPageChanged: (page) =>
                                setState(() => _currentPage = page),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    final theme = Theme.of(context);
    // Real statuses might differ, sticking to the existing constants for UI
    final statuses = ["All Status", "Cold", "Warm", "Hot", "Booked"];

    return PopupMenuButton<String>(
      onSelected: (String status) {
        setState(() {
          _selectedStatus = status;
          _currentPage = 1;
        });
      },
      itemBuilder: (BuildContext context) {
        return statuses.map((String status) {
          return PopupMenuItem<String>(
            value: status,
            child: Text(status),
          );
        }).toList();
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerTheme.color ?? Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 18,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 6),
            Text(
              _selectedStatus,
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}