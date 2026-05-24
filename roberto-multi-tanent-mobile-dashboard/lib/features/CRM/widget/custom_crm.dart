import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/custom_search.dart';
import 'package:roberto/features/CRM/widget/custom_lead_row.dart';
import 'package:roberto/features/Tenant Management /widget/custom_headder.dart';
import 'package:roberto/features/CRM/widget/crm_lead_model.dart';
import 'package:roberto/common/custom_pagination.dart';

class CustomCrm extends StatefulWidget {
  final Function(String)? onNavigate;
  const CustomCrm({super.key, this.onNavigate});

  @override
  State<CustomCrm> createState() => _CustomCrmState();
}

class _CustomCrmState extends State<CustomCrm> {
  String _selectedStatus = "All Status";
  int _currentPage = 1;
  static const int _itemsPerPage = 20;

  final List<CRMLead> _leads = [
     CRMLead(
      name: "Sarah Johnson",
      email: "sarah.j@email.com",
      phone: "++1 234 567 8901",
      socialText: "Facebook",
      socialIcon: "assets/facebook.svg",
      tagText: "Cold",
      tagColor: AppColor.deepgreen,
      time: "2 hours ago",
      notes: "Interested in premium products and services.",
    ),
    CRMLead(
      name: "Michael Chen",
      email: "m.chen@email.com",
      phone: "++1 234 567 8901",
      socialText: "WhatsApp",
      socialIcon: "assets/whatsapp.svg",
      tagText: "Warm",
      tagColor: AppColor.greens,
      time: "1 day ago",
      notes: "Follow up next week for demo.",
    ),
    CRMLead(
      name: "Emma Wilson",
      email: "emma.w@email.com",
      phone: "+1 234 567 8903",
      socialText: "Instagram",
      socialIcon: "assets/instagram.svg",
      tagText: "Booked",
      tagColor: AppColor.ma,
      time: "3 hours ago",
      notes: "Meeting scheduled for Friday.",
    ),
    CRMLead(
      name: "David Brown",
      email: "d.brown@email.com",
      phone: "+1 234 567 8904",
      socialText: "Facebook",
      socialIcon: "assets/facebook.svg",
      tagText: "Hot",
      tagColor: AppColor.primary,
      time: "5 days ago",
      notes: "Ready for contract signing.",
    ),
    CRMLead(
      name: "Alice Cooper",
      email: "alice.c@email.com",
      phone: "+1 234 567 8910",
      socialText: "Facebook",
      socialIcon: "assets/facebook.svg",
      tagText: "Cold",
      tagColor: AppColor.deepgreen,
      time: "10 hours ago",
      notes: "Potential for bulk order.",
    ),
    CRMLead(
      name: "Bob Dylan",
      email: "bob.d@email.com",
      phone: "+1 234 567 8911",
      socialText: "WhatsApp",
      socialIcon: "assets/whatsapp.svg",
      tagText: "Warm",
      tagColor: AppColor.greens,
      time: "2 days ago",
      notes: "Wants to see the full catalog.",
    ),
    ...List.generate(
      25,
      (index) => CRMLead(
        name: "Lead ${index + 1}",
        email: "lead${index + 1}@email.com",
        phone: "+1 234 567 ${8000 + index}",
        socialText: ["Facebook", "WhatsApp", "Instagram"][index % 3],
        socialIcon: [
          "assets/facebook.svg",
          "assets/whatsapp.svg",
          "assets/instagram.svg"
        ][index % 3],
        tagText: ["Cold", "Warm", "Hot", "Booked"][index % 4],
        tagColor: [
          AppColor.deepgreen,
          AppColor.greens,
          AppColor.primary,
          AppColor.ma
        ][index % 4],
        time: "${index + 1} hours ago",
        notes: "Notes for lead ${index + 1}",
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    final theme = Theme.of(context);

    final filteredLeads = _selectedStatus == "All Status"
        ? _leads
        : _leads.where((lead) => lead.tagText == _selectedStatus).toList();

    final paginatedLeads = filteredLeads.sublist(
      (_currentPage - 1) * _itemsPerPage,
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
                  ...paginatedLeads.map((lead) => CustomLeadRow(
                        name: lead.name,
                        email: lead.email,
                        phone: lead.phone,
                        socialText: lead.socialText,
                        socialIcon: lead.socialIcon,
                        tagText: lead.tagText,
                        tagColor: lead.tagColor,
                        time: lead.time,
                        notes: lead.notes,
                        onNavigate: widget.onNavigate,
                      )),
                  if (filteredLeads.isNotEmpty)
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
  }

  Widget _buildStatusButton(BuildContext context) {
    final theme = Theme.of(context);
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