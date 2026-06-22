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

class WhatsAppCampaignsScreen extends StatefulWidget {
  const WhatsAppCampaignsScreen({super.key});

  @override
  State<WhatsAppCampaignsScreen> createState() => _WhatsAppCampaignsScreenState();
}

class _WhatsAppCampaignsScreenState extends State<WhatsAppCampaignsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CampaignBloc>().add(FetchCampaigns());
  }

  void _showCampaignDialog({bool isReadOnly = false, CampaignModel? initialData}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: CreateCampaignForm(
          isReadOnly: isReadOnly,
          initialData: initialData,
          onCancel: () => Navigator.pop(context),
          onCreate: (data) {
            if (initialData != null) {
              context.read<CampaignBloc>().add(
                UpdateCampaign(
                  id: initialData.id,
                  name: data['name'],
                  endDate: data['endDate'],
                ),
              );
            } else {
              context.read<CampaignBloc>().add(
                CreateCampaign(
                  name: data['name'],
                  branchId: 'cmqoiy10j000604l6b1iif72l', // Using a dummy ID or requires selection
                  message: 'Generated campaign for ${data['audience']}',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "WhatsApp campaigns",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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
              ),
              ElevatedButton.icon(
                onPressed: () => _showCampaignDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Create Campaign", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
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
                        final campaign = campaigns[index];
                        return CampaignCard(
                          title: campaign.name,
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
