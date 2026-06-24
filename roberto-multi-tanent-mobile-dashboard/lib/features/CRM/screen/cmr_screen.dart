import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/CRM/widget/custom_crm.dart';
import 'package:roberto/features/CRM/widget/custom_addlead.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_stat_card.dart';
import 'package:roberto/common/user_role.dart';
import 'package:roberto/features/CRM/bloc/crm_bloc.dart';
import 'package:roberto/features/CRM/bloc/crm_state.dart';

class CmrScreen extends StatefulWidget {
  final Function(String)? onNavigate;
  final UserRole role;
  const CmrScreen({super.key, this.onNavigate, this.role = UserRole.businessOwner});

  @override
  State<CmrScreen> createState() => _CmrScreenState();
}

class _CmrScreenState extends State<CmrScreen> {
  int _totalLeads = 0;
  int _totalBooked = 0;
  int _callLead = 0;

  Widget _buildAddLeadButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CustomAddlead(role: widget.role),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              "Add Lead",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(double width) {
    final cards = [
      CustomStatCard(
        label: 'Total Leads',
        value: _totalLeads.toString(),
        iconPath: 'assets/lead.svg',
      ),
      CustomStatCard(
        label: 'Total Booked',
        value: _totalBooked.toString(),
        iconPath: 'assets/book.svg',
      ),
      CustomStatCard(
        label: 'Call Leads',
        value: _callLead.toString(),
        iconPath: 'assets/value.svg',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width < 640 ? 1 : (width < 1000 ? 2 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 115,
      ),
      itemBuilder: (context, index) {
        return cards[index];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return BlocConsumer<CrmBloc, CrmState>(
      listener: (context, state) {
        if (state is CrmLeadsLoaded) {
          setState(() {
            final meta = state.meta;
            _totalLeads = int.tryParse(meta?['totalCount']?.toString() ?? '') ?? 0;
            _totalBooked = int.tryParse(meta?['totalBooked']?.toString() ?? '') ?? 0;
            _callLead = int.tryParse(meta?['callLead']?.toString() ?? '') ?? 0;
          });
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              width < 600
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CRM & Leads',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAddLeadButton(context),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CRM & Leads',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildAddLeadButton(context),
                      ],
                    ),
              const SizedBox(height: 6),
              Text(
                'Manage leads and customer relationships',
                style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 20),
              _buildStatCards(width),
              const SizedBox(height: 25),
              CustomCrm(onNavigate: widget.onNavigate, role: widget.role),
            ],
          ),
        );
      },
    );
  }
}
