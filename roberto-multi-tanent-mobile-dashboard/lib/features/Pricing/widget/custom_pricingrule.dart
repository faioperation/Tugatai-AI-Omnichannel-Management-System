import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/custom_pagination.dart';
import 'package:roberto/features/Pricing/widget/custom_widgetrule.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_headder.dart';

import 'package:roberto/features/Pricing/widget/pricing_rule_mod.dart';
import 'package:roberto/features/Pricing/widget/custom_addrule.dart';

class CustomPricingrule extends StatefulWidget {
  final List<PricingRuleMod> rules;
  final Function(PricingRuleMod) onEdit;
  final Function(String) onDelete;

  const CustomPricingrule({
    super.key,
    required this.rules,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CustomPricingrule> createState() => _CustomPricingruleState();
}

class _CustomPricingruleState extends State<CustomPricingrule> {
  int _currentPage = 1;
  static const int _itemsPerPage = 20;

  List<PricingRuleMod> get _paginatedRules {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (startIndex >= widget.rules.length) return [];
    return widget.rules.sublist(
      startIndex,
      endIndex > widget.rules.length ? widget.rules.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pricing Rules",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Configure automatic pricing based on weight, product type, or custom conditions",
            style: TextStyle(
              fontSize: 15,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 26),
          if (isDesktop)
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      color: isDark
                          ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
                          : AppColor.secondary,
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomHeadder(
                                label: 'Rule Name',
                                textAlign: TextAlign.start),
                          ),
                          Expanded(
                            flex: 3,
                            child: CustomHeadder(
                                label: 'Type', textAlign: TextAlign.start),
                          ),
                          Expanded(
                            flex: 3,
                            child: CustomHeadder(
                                label: 'Configuration',
                                textAlign: TextAlign.start),
                          ),
                          Expanded(
                            flex: 2,
                            child: CustomHeadder(
                                label: 'Status', textAlign: TextAlign.start),
                          ),
                          Expanded(
                            flex: 2,
                            child: CustomHeadder(
                                label: 'Actions', textAlign: TextAlign.start),
                          ),
                        ],
                      ),
                    ),
                    ..._paginatedRules.map((rule) => CustomWidgetrule(
                          key: ValueKey(rule.id),
                          title: rule.name,
                          badgeText: rule.type,
                          description: rule.value,
                          onEdit: () => widget.onEdit(rule),
                          onDelete: () => widget.onDelete(rule.id),
                        )),
                    if (widget.rules.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomPagination(
                          totalItems: widget.rules.length,
                          itemsPerPage: _itemsPerPage,
                          currentPage: _currentPage,
                          onPageChanged: (page) =>
                              setState(() => _currentPage = page),
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ..._paginatedRules.map((rule) => CustomWidgetrule(
                      key: ValueKey(rule.id),
                      title: rule.name,
                      badgeText: rule.type,
                      description: rule.value,
                      onEdit: () => widget.onEdit(rule),
                      onDelete: () => widget.onDelete(rule.id),
                    )),
                if (widget.rules.isNotEmpty)
                  CustomPagination(
                    totalItems: widget.rules.length,
                    itemsPerPage: _itemsPerPage,
                    currentPage: _currentPage,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}