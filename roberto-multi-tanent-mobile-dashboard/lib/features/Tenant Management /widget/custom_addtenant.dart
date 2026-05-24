import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/Custom_Minitextfield.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/Custom_MiniDropdown.dart';

class CustomAddtenant extends StatefulWidget {
  const CustomAddtenant({super.key});

  @override
  State<CustomAddtenant> createState() => _CustomAddtenantState();
}

class _CustomAddtenantState extends State<CustomAddtenant> {
  int selectedTab = 0;
  String selectedBusinessType = "";
  String selectedBranch = "2";
  String selectedPlan = "Half Moon - \$49/mo";
  String selectedBillingCycle = "Monthly";

  void changeTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width < 600
            ? MediaQuery.of(context).size.width * 0.9
            : 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Onboard New Client",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Set up a new business account with all required information",
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // Tabs (ONLY CHANGE HERE)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _tabItem("Business Info", 0),
                  _tabItem("Owner Details", 1),
                  _tabItem("Plan & Settings", 2),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ONLY TAB SWITCH LOGIC ADDED
            if (selectedTab == 0) _businessInfo(),
            if (selectedTab == 1) _ownerDetails(),
            if (selectedTab == 2) _planSettings(),

            const SizedBox(height: 20),

            // Buttons (UNCHANGED)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(color: AppColor.white, fontSize: 13),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // TAB ITEM (ONLY SMALL CHANGE)
  Widget _tabItem(String text, int index) {
    final active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: active ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- TAB CONTENTS (SAME UI)

  Widget _businessInfo() {
    return Column(
      children: [
        _inputLabel("Business Name"),
        const SizedBox(height: 5),
        const CustomMinitextfield(hint: "Enter business name"),

        const SizedBox(height: 12),

        _inputLabel("Business Type"),
        const SizedBox(height: 5),
        CustomMiniDropdown(
          value: selectedBusinessType,
          items: const ["Retail", "Service", "Manufacturing", "Tech", "Other"],
          hint: "Select type",
          onChanged: (val) => setState(() => selectedBusinessType = val ?? ""),
        ),

        const SizedBox(height: 12),

        _inputLabel("Select Branch"),
        const SizedBox(height: 5),
        CustomMiniDropdown(
          value: selectedBranch,
          items: const ["1", "2", "3", "4", "5"],
          hint: "Select branch",
          onChanged: (val) => setState(() => selectedBranch = val ?? ""),
        ),

        const SizedBox(height: 12),

        _inputLabel("Description"),
        const SizedBox(height: 5),
        const CustomMinitextfield(
          hint: "Brief description of the business...",
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _ownerDetails() {
    return Column(
      children: [
        _inputLabel("Owner Name"),
        const SizedBox(height: 5),
        CustomMinitextfield(hint: "Enter owner name"),

        const SizedBox(height: 12),

        _inputLabel("Email"),
        const SizedBox(height: 5),
        CustomMinitextfield(hint: "Enter email"),

        const SizedBox(height: 12),

        _inputLabel("Phone"),
        const SizedBox(height: 5),
        CustomMinitextfield(hint: "Enter phone"),

        const SizedBox(height: 12),

        _inputLabel("Initial Password"),
        const SizedBox(height: 5),
        CustomMinitextfield(hint: "Create password"),
      ],
    );
  }

  Widget _planSettings() {
    return Column(
      children: [
        _inputLabel("Subscription Plan"),
        const SizedBox(height: 5),
        CustomMiniDropdown(
          value: selectedPlan,
          items: const ["Half Moon - \$49/month", "Full Moon - \$199/month", "Moon Enterprise - \$499/month"],
          hint: "Select plan",
          onChanged: (val) => setState(() => selectedPlan = val ?? ""),
        ),

        const SizedBox(height: 12),

        _inputLabel("Billing Cycle"),
        const SizedBox(height: 5),
        CustomMiniDropdown(
          value: selectedBillingCycle,
          items: const ["Monthly", "Yearly"],
          hint: "Select cycle",
          onChanged: (val) => setState(() => selectedBillingCycle = val ?? ""),
        ),
      ],
    );
  }

  Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}