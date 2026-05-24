import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/features/Pricing/widget/custom_addrule.dart';
import 'package:roberto/features/Pricing/widget/custom_pricingrule.dart';
import 'package:roberto/features/Pricing/widget/custom_pricingcalculator.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_headder.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_stat_card.dart';

import 'package:roberto/features/Pricing/widget/pricing_rule_mod.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  int _selectedTab = 0;

  final List<PricingRuleMod> _rules = [
    ...List.generate(
      25,
      (index) => PricingRuleMod(
        id: '${index + 1}',
        name: "Pricing Rule ${index + 1}",
        type: ["weight", "product type", "custom"][index % 3],
        value: "Value ${index + 1}",
      ),
    ),
  ];

  void _openAddRuleDialog({PricingRuleMod? rule}) {
    showDialog(
      context: context,
      builder: (context) => CustomAddrule(
        rule: rule,
        onSave: (newRule) {
          setState(() {
            if (rule != null) {
              final index = _rules.indexWhere((r) => r.id == rule.id);
              if (index != -1) {
                _rules[index] = newRule;
              }
            } else {
              _rules.add(newRule);
            }
          });
        },
      ),
    );
  }

  Widget _buildAddRuleButton(BuildContext context) {
    return InkWell(
      onTap: () => _openAddRuleDialog(),
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
            const Icon(Icons.add, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              "Add Rule",
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
        label: 'Base Rate',
        value: '\$15/kg',
        iconPath: 'assets/rate.svg',
      ),
      CustomStatCard(
        label: 'Active Rules',
        value: _rules.length.toString(),
        iconPath: 'assets/rule.svg',
      ),
      CustomStatCard(
        label: 'Categories',
        value: '5',
        iconPath: 'assets/categori.svg',
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          width < 600
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAddRuleButton(context),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Pricing Management',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildAddRuleButton(context),
                  ],
                ),
          const SizedBox(height: 6),
          Text(
            'Manage pricing rules and product categories',
            style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 20),
          _buildStatCards(width),
          const SizedBox(height: 25),
          _buildToggleTabs(),
          const SizedBox(height: 25),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: _selectedTab == 0
                ? CustomPricingrule(
                    key: const ValueKey('Pricing Rules'),
                    rules: _rules,
                    onEdit: (rule) => _openAddRuleDialog(rule: rule),
                    onDelete: (id) {
                      setState(() {
                        _rules.removeWhere((r) => r.id == id);
                      });
                    },
                  )
                : const CustomPricingcalculator(
                    key: ValueKey('Price Calculator')),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabs() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(index: 0, label: 'Pricing Rules'),
          _buildTab(index: 1, label: 'Price Calculator'),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isActive = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
    );
  }
}