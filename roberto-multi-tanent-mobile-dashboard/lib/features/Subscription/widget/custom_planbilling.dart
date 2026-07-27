import 'package:flutter/material.dart';
import 'package:roberto/features/Subscription/widget/custom_plan.dart';
import 'package:roberto/features/Subscription/widget/custom_billing.dart';
import 'package:roberto/features/Subscription/data/models/subscription_model.dart';

import '../../../app/app_color.dart';

class CustomPlanbilling extends StatefulWidget {
  final SystemOwnerSubscriptionModel subscriptionData;

  const CustomPlanbilling({super.key, required this.subscriptionData});

  @override
  State<CustomPlanbilling> createState() => _CustomPlanbillingState();
}

class _CustomPlanbillingState extends State<CustomPlanbilling> {
  int _selectedIndex = 0;
  bool _isYearly = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleBar(),
        const SizedBox(height: 45),
        if (_selectedIndex == 0) _buildBillingToggle(Theme.of(context), Theme.of(context).brightness == Brightness.dark),
        _selectedIndex == 0 ? _buildPlansContent() : _buildBillingContent(),
      ],
    );
  }

  Widget _buildToggleBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? theme.colorScheme.secondary
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabButton('Plans', 0),
          _tabButton('Billing History', 1),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final theme = Theme.of(context);
    final isActive = _selectedIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColor.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingToggle(ThemeData theme, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _isYearly = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: !_isYearly ? AppColor.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Monthly",
                    style: TextStyle(
                      color: !_isYearly ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _isYearly = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isYearly ? AppColor.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Yearly",
                        style: TextStyle(
                          color: _isYearly ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "10% Off",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;
        bool isTablet = constraints.maxWidth > 600;

        final plans = widget.subscriptionData.plans.map((plan) {
          // Provide an icon based on slug/name or fallback to a default
          String iconPath = "assets/half.svg";
          if (plan.slug == 'convert') iconPath = "assets/full.svg";
          if (plan.slug == 'control') iconPath = "assets/enter.svg";

          final price = _isYearly ? plan.yearlyPrice : plan.monthlyPrice;
          final period = _isYearly ? "/year" : "/month";

          return CustomPlan(
            title: plan.name,
            subtitle: plan.description,
            price: "\$${price.toStringAsFixed(0)}",
            iconPath: iconPath,
            features: plan.features.map((f) => f.value).toList(),
            billingPeriod: period,
          );
        }).toList();

        if (plans.isEmpty) {
          return const Center(child: Text("No plans available."));
        }

        // 💻 Desktop
        if (isDesktop) {
          return Row(
            children: plans
                .map((p) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: plans.last == p ? 0 : 16),
                child: p,
              ),
            ))
                .toList(),
          );
        }

        // 📱 Tablet
        else if (isTablet) {
          return Column(
            children: [
              if (plans.length >= 2) ...[
                Row(
                  children: [
                    Expanded(child: plans[0]),
                    const SizedBox(width: 16),
                    Expanded(child: plans[1]),
                  ],
                ),
                const SizedBox(height: 16),
              ] else if (plans.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(child: plans[0]),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              if (plans.length > 2) ...plans.sublist(2),
            ],
          );
        }

        // 📱 Mobile
        else {
          return Column(
            children: plans
                .map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: p,
            ))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildBillingContent() {
    return CustomBilling(billingHistory: widget.subscriptionData.billingHistory);
  }
}