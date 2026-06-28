import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/WhatsAppCampaigns/bloc/campaign_bloc.dart';
import 'package:roberto/features/WhatsAppCampaigns/bloc/campaign_event.dart';
import 'package:roberto/features/WhatsAppCampaigns/bloc/campaign_state.dart';
import 'package:roberto/features/WhatsAppCampaigns/data/models/campaign_model.dart';
import 'package:roberto/features/WhatsAppCampaigns/widget/campaign_card.dart';
import 'package:roberto/features/WhatsAppCampaigns/widget/create_campaign_form.dart';
import 'package:roberto/features/management/bloc/management_bloc.dart';
import 'package:roberto/features/management/bloc/management_state.dart';
import 'package:roberto/features/management/data/models/branch_model.dart';

class WhatsAppCampaignsScreen extends StatefulWidget {
  final String? branchId;
  const WhatsAppCampaignsScreen({super.key, this.branchId});

  @override
  State<WhatsAppCampaignsScreen> createState() => _WhatsAppCampaignsScreenState();
}

class _WhatsAppCampaignsScreenState extends State<WhatsAppCampaignsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant WhatsAppCampaignsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId) {
      _fetchData();
    }
  }

  void _fetchData() {
    context.read<CampaignBloc>().add(FetchCampaigns(branchId: widget.branchId));
  }

  void _showCampaignDialog({bool isReadOnly = false, CampaignModel? initialData}) {
    List<BranchModel> branches = [];
    final managementState = context.read<ManagementBloc>().state;
    if (managementState is ManagementLoaded) {
      branches = managementState.branches;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: CreateCampaignForm(
          isReadOnly: isReadOnly,
          initialData: initialData,
          branches: branches,
          currentBranchId: widget.branchId,
          onCancel: () => Navigator.pop(context),
          onCreate: (data) {
            if (initialData != null) {
              context.read<CampaignBloc>().add(
                UpdateCampaign(
                  id: initialData.id,
                  title: data['title'],
                  message: data['message'],
                  branchId: data['branchId'],
                  selectedPeople: data['selectedPeople'],
                  scheduledTime: data['scheduledTime'],
                  endDate: data['endDate'],
                ),
              );
            } else {
              context.read<CampaignBloc>().add(
                CreateCampaign(
                  title: data['title'],
                  message: data['message'],
                  branchId: data['branchId'],
                  selectedPeople: data['selectedPeople'],
                  scheduledTime: data['scheduledTime'],
                  endDate: data['endDate'],
                ),
              );
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              
              final titleCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WhatsApp campaigns",
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create and manage your WhatsApp marketing campaigns",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              );
              
              final createBtn = ElevatedButton.icon(
                onPressed: () => _showCampaignDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Create Campaign", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleCol,
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: createBtn),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleCol),
                  const SizedBox(width: 16),
                  createBtn,
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          BlocConsumer<CampaignBloc, CampaignState>(
            listener: (context, state) {
              if (state is CampaignActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is CampaignError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              if (state is CampaignLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CampaignLoaded) {
                final campaigns = state.campaigns;
                if (campaigns.isEmpty) {
                  return const Center(child: Text("No campaigns found"));
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
                    if (constraints.maxWidth > 1400) crossAxisCount = 3;
                    
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        mainAxisExtent: 310,
                      ),
                      itemCount: campaigns.length,
                      itemBuilder: (context, index) {
                        CampaignModel campaign = campaigns[index];
                        return CampaignCard(
                          title: campaign.title,
                          status: campaign.status,
                          date: DateFormat('MMM dd, yyyy').format(campaign.createdAt),
                          description: campaign.message,
                          onView: () => _showCampaignDialog(isReadOnly: true, initialData: campaign),
                          onEdit: () => _showCampaignDialog(isReadOnly: false, initialData: campaign),
                          onDelete: () {
                            context.read<CampaignBloc>().add(DeleteCampaign(id: campaign.id));
                          },
                        );
                      },
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
