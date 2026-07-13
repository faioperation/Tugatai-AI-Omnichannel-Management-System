import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/features/Pricing/widget/custom_addrule.dart';
import 'package:roberto/features/Pricing/widget/custom_pricingrule.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_bloc.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_state.dart';
import 'package:roberto/features/Pricing/widget/custom_pricingcalculator.dart';
import 'package:roberto/features/TenantManagement/widget/custom_headder.dart';
import 'package:roberto/features/TenantManagement/widget/custom_stat_card.dart';
import 'package:roberto/features/Pricing/widget/pricing_rule_mod.dart';
import 'package:roberto/features/Pricing/bloc/pricing_bloc.dart';
import 'package:roberto/features/Pricing/bloc/pricing_event.dart';
import 'package:roberto/features/Pricing/bloc/pricing_state.dart';
import 'package:roberto/common/user_role.dart';

class PricingScreen extends StatefulWidget {
  final UserRole role;
  final String? branchId;

  const PricingScreen({super.key, this.role = UserRole.businessOwner, this.branchId});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  int _selectedTab = 0;
  List<PricingRuleMod> _rules = [];
  bool _isLoading = true;
  int _totalRules = 0;
  int _activeRules = 0;
  int _typeCounts = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant PricingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId) {
      _fetchData();
    }
  }

  void _fetchData() {
    context.read<PricingBloc>().add(FetchPricingRules(role: widget.role, branchId: widget.branchId));
  }

  void _openAddRuleDialog({PricingRuleMod? rule}) {
    final currentBranchId = widget.branchId ?? '';
    
    showDialog(
      context: context,
      builder: (context) => CustomAddrule(
        rule: rule,
        onSave: (newRule) {
          Map<String, dynamic> configMap;
          try {
            final decoded = jsonDecode(newRule.value);
            if (decoded is Map<String, dynamic>) {
              configMap = decoded;
            } else {
              configMap = {'value': newRule.value};
            }
          } catch (_) {
            configMap = {'value': newRule.value};
          }

          if (rule != null) {
            context.read<PricingBloc>().add(UpdatePricingRule(
                  id: rule.id,
                  ruleName: newRule.name,
                  type: newRule.type,
                  configuration: configMap,
                  status: newRule.isActive,
                  branchId: rule.branchId ?? currentBranchId,
                  role: widget.role,
                ));
          } else {
            context.read<PricingBloc>().add(CreatePricingRule(
                  ruleName: newRule.name,
                  type: newRule.type,
                  configuration: configMap,
                  status: newRule.isActive,
                  branchId: currentBranchId,
                  role: widget.role,
                ));
          }
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
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 6),
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
        label: 'Total Rules',
        value: _totalRules.toString(),
        iconPath: 'assets/rate.svg',
      ),
      CustomStatCard(
        label: 'Active Rules',
        value: _activeRules.toString(),
        iconPath: 'assets/rule.svg',
      ),
      CustomStatCard(
        label: 'Categories',
        value: _typeCounts.toString(),
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

    return BlocConsumer<PricingBloc, PricingState>(
      listener: (context, state) {
        if (state is PricingLoaded) {
          setState(() {
            _rules = state.rules;
            _isLoading = false;
            _totalRules = state.total;
            _activeRules = state.activeCount;
            _typeCounts = state.typeCounts;
          });
        } else if (state is PricingLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is PricingError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is PricingActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
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
                    ? _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomPricingrule(
                            key: const ValueKey('Pricing Rules'),
                            rules: _rules,
                            onEdit: (rule) => _openAddRuleDialog(rule: rule),
                            onDelete: (id) {
                              context.read<PricingBloc>().add(DeletePricingRule(id: id, role: widget.role));
                            },
                          )
                    : BlocBuilder<BusinessSubscriptionBloc, BusinessSubscriptionState>(
                        builder: (context, subState) {
                          bool isConnectPlan = false;
                          if (subState is BusinessSubscriptionLoaded && subState.subscriptions.isNotEmpty) {
                            final planSlug = subState.subscriptions.first.plan?.slug.toLowerCase();
                            if (planSlug == 'connect') {
                              isConnectPlan = true;
                            }
                          }

                          if (isConnectPlan) {
                            return Container(
                              padding: const EdgeInsets.all(40),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
                              ),
                              child: Text(
                                'purches convert or control plan to get this features',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return CustomPricingcalculator(
                            key: const ValueKey('Price Calculator'),
                            rules: _rules,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
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