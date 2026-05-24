import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/WhatsAppCampaigns/widget/campaign_card.dart';
import 'package:roberto/features/WhatsAppCampaigns/widget/create_campaign_form.dart';

class WhatsAppCampaignsScreen extends StatefulWidget {
  const WhatsAppCampaignsScreen({super.key});

  @override
  State<WhatsAppCampaignsScreen> createState() => _WhatsAppCampaignsScreenState();
}

class _WhatsAppCampaignsScreenState extends State<WhatsAppCampaignsScreen> {
  final List<Map<String, dynamic>> _campaigns = [
    {
      "title": "kenya campagin",
      "status": "Completed",
      "date": "Jan 18, 2026",
      "description": "📦 🚀 NEW-YEAR SHIPPING SCHEDULE 🇰🇪 ➡️ 🇸🇴 Batch 183 – Kenya 📦 Rate: 13QAR/kg 💰 Doha Customs: 75...",
      "inbox": "Inbox 1",
      "template": "Template 1",
      "audience": "Hot",
    },
    {
      "title": "test2",
      "status": "Completed",
      "date": "Jan 18, 2026",
      "description": "📦 🚀 NEW-YEAR SHIPPING SCHEDULE 🇰🇪 ➡️ 🇸🇴 Batch 183 – Kenya 📦 Rate: 13QAR/kg 💰 Doha Customs: 75...",
      "inbox": "Inbox 2",
      "template": "Template 2",
      "audience": "Cold",
    },
  ];

  void _showCampaignDialog({bool isReadOnly = false, Map<String, dynamic>? initialData}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: CreateCampaignForm(
          isReadOnly: isReadOnly,
          initialData: initialData,
          onCancel: () => Navigator.pop(context),
          onCreate: () {
            // Implement create/update logic here
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(initialData != null ? "Campaign updated successfully" : "Campaign created successfully")),
            );
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
          LayoutBuilder(
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
                itemCount: _campaigns.length,
                itemBuilder: (context, index) {
                  final campaign = _campaigns[index];
                  return CampaignCard(
                    title: campaign['title'],
                    status: campaign['status'],
                    date: campaign['date'],
                    description: campaign['description'],
                    onView: () => _showCampaignDialog(isReadOnly: true, initialData: campaign),
                    onEdit: () => _showCampaignDialog(isReadOnly: false, initialData: campaign),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
