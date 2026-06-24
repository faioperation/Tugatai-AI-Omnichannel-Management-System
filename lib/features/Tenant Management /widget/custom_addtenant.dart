import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Tenant Management /widget/custom_minitextfield.dart';
import 'package:roberto/features/Tenant Management /widget/Custom_MiniDropdown.dart';
import 'package:roberto/features/Tenant Management /bloc/tenant_bloc.dart';
import 'package:roberto/features/Tenant Management /bloc/tenant_event.dart';
import 'package:roberto/features/Subscription/bloc/subscription_bloc.dart';
import 'package:roberto/features/Subscription/bloc/subscription_state.dart';
import 'package:roberto/features/Subscription/bloc/subscription_event.dart';

class CustomAddtenant extends StatefulWidget {
  const CustomAddtenant({super.key});

  @override
  State<CustomAddtenant> createState() => _CustomAddtenantState();
}

class _CustomAddtenantState extends State<CustomAddtenant> {
  int selectedTab = 0;
  
  // Form controllers
  final _businessNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Dropdown states
  String selectedBusinessType = "RETAIL"; // Matches backend enum or generic
  String selectedIndustry = "CARGO";
  String selectedPlanId = "";
  String selectedBillingCycle = "MONTHLY";

  @override
  void initState() {
    super.initState();
    // Ensure plans are loaded
    context.read<SubscriptionBloc>().add(FetchSubscriptionsRequested());
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void changeTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  void _submit() {
    final payload = {
      "businessName": _businessNameCtrl.text,
      "businessType": selectedBusinessType,
      "industry": selectedIndustry,
      "description": _descriptionCtrl.text,
      "ownerName": _ownerNameCtrl.text,
      "ownerEmail": _emailCtrl.text,
      "ownerPassword": _passwordCtrl.text,
      "ownerPhone": _phoneCtrl.text,
      "planId": selectedPlanId.isNotEmpty ? selectedPlanId : "some-default-plan-id",
      "planCycle": selectedBillingCycle,
      "credits": 0,
    };

    context.read<TenantBloc>().add(CreateTenantRequested(payload: payload));
    Navigator.pop(context); // Close modal, user can see success message via state if implemented.
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

            // Tabs
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

            // Form content
            if (selectedTab == 0) _businessInfo(),
            if (selectedTab == 1) _ownerDetails(),
            if (selectedTab == 2) _planSettings(),

            const SizedBox(height: 20),

            // Buttons
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
                  onPressed: _submit,
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

  Widget _tabItem(String text, int index) {
    final active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
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

  Widget _businessInfo() {
    return Column(
      children: [
        _inputLabel("Business Name"),
        const SizedBox(height: 5),
        CustomMinitextfield(hint: "Enter business name", controller: _businessNameCtrl),

        const SizedBox(height: 12),

        _inputLabel("Business Type"),
        const SizedBox(height: 5),
        CustomMiniDropdown(
          value: selectedBusinessType,
          items: const ["RETAIL", "SERVICE", "MANUFACTURING", "PARCEL_DELIVERY", "OTHER"],
          hint: "Select type",
          onChanged: (val) => setState(() => selectedBusinessType = val ?? "RETAIL"),
        ),

        const SizedBox(height: 12),

        _inputLabel("Industry"),
        const SizedBox(height: 5),
        CustomMiniDropdown(
          value: selectedIndustry,
          items: const ["CARGO", "ECOMMERCE", "FOOD_DELIVERY", "OTHER"],
          hint: "Select industry",
          onChanged: (val) => setState(() => selectedIndustry = val ?? "CARGO"),
        ),

        const SizedBox(height: 12),

        _inputLabel("Description"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Brief description of the business...",
          maxLines: 3,
          controller: _descriptionCtrl,
        ),
      ],
    );
  }

  Widget _ownerDetails() {
    return Column(
      children: [
        _inputLabel("Owner Name"),
        const SizedBox(height: 5),
        CustomMinitextfield(hint: "Enter owner name", controller: _ownerNameCtrl),

        const SizedBox(height: 12),

        _inputLabel("Email"),
        const SizedBox(height: 5),
        CustomMinitextfield(hint: "Enter email", controller: _emailCtrl),

        const SizedBox(height: 12),

        _inputLabel("Phone"),
        const SizedBox(height: 5),
        CustomMinitextfield(hint: "Enter phone (+880...)", controller: _phoneCtrl),

        const SizedBox(height: 12),

        _inputLabel("Initial Password"),
        const SizedBox(height: 5),
        CustomMinitextfield(hint: "Create password", controller: _passwordCtrl, obscureText: true),
      ],
    );
  }

  Widget _planSettings() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<String> planOptions = ["No Plans Found"];
        Map<String, String> planMap = {}; // name -> id

        if (state is SubscriptionLoaded) {
          final plans = state.subscriptionData.plans;
          if (plans.isNotEmpty) {
            planOptions = [];
            for (var plan in plans) {
              planOptions.add(plan.name);
              planMap[plan.name] = plan.id;
            }
            if (selectedPlanId.isEmpty || !planMap.values.contains(selectedPlanId)) {
              selectedPlanId = plans.first.id;
            }
          }
        }

        String currentPlanName = planMap.entries
            .firstWhere((e) => e.value == selectedPlanId, orElse: () => const MapEntry("Select plan", ""))
            .key;
            
        if (!planOptions.contains(currentPlanName)) {
           if(planOptions.isNotEmpty){
             currentPlanName = planOptions.first;
           }
        }

        return Column(
          children: [
            _inputLabel("Subscription Plan"),
            const SizedBox(height: 5),
            CustomMiniDropdown(
              value: currentPlanName,
              items: planOptions,
              hint: "Select plan",
              onChanged: (val) {
                if (val != null && planMap.containsKey(val)) {
                  setState(() => selectedPlanId = planMap[val]!);
                }
              },
            ),

            const SizedBox(height: 12),

            _inputLabel("Billing Cycle"),
            const SizedBox(height: 5),
            CustomMiniDropdown(
              value: selectedBillingCycle,
              items: const ["MONTHLY", "YEARLY"],
              hint: "Select cycle",
              onChanged: (val) => setState(() => selectedBillingCycle = val ?? "MONTHLY"),
            ),
          ],
        );
      },
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