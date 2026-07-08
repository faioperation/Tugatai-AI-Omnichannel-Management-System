import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/custom_button.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';
import 'package:roberto/features/Pricing/widget/pricing_rule_mod.dart';
import 'package:roberto/features/Pricing/data/repositories/pricing_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomPricingcalculator extends StatefulWidget {
  final List<PricingRuleMod> rules;
  const CustomPricingcalculator({super.key, this.rules = const []});

  @override
  State<CustomPricingcalculator> createState() => _CustomPricingcalculatorState();
}

class _CustomPricingcalculatorState extends State<CustomPricingcalculator> {
  final TextEditingController quantityController = TextEditingController(text: "1");
  final TextEditingController weightController = TextEditingController(text: "1.0");
  final TextEditingController distanceController = TextEditingController(text: "10.0");
  
  PricingRuleMod? selectedRule;
  String selectedServiceType = "standard";
  Map<String, bool> extrasCheckboxes = {};
  final _formKey = GlobalKey<FormState>();
  
  bool isLoading = false;
  Map<String, dynamic>? calculationResult;
  String? errorMessage;

  int get quantity => int.tryParse(quantityController.text) ?? 1;

  @override
  void initState() {
    super.initState();
    // Default to the first active rule if available
    final activeRules = widget.rules.where((r) => r.isActive).toList();
    if (activeRules.isNotEmpty) {
      selectedRule = activeRules.first;
      _updateRuleFields(selectedRule!);
    }
  }

  void _updateRuleFields(PricingRuleMod rule) {
    // Determine service types & extras from rule configuration
    final config = rule.rawConfiguration;
    extrasCheckboxes.clear();
    
    if (config != null) {
      // Extras
      final additionalCharges = config['additionalCharges'];
      if (additionalCharges is Map) {
        additionalCharges.forEach((key, value) {
          extrasCheckboxes[key.toString()] = false;
        });
      }
      
      // Service Types
      final serviceTypes = config['serviceTypes'];
      if (serviceTypes is Map && serviceTypes.isNotEmpty) {
        selectedServiceType = serviceTypes.keys.first.toString();
      } else {
        selectedServiceType = "standard";
      }
    } else {
      selectedServiceType = "standard";
    }
  }

  void increase() {
    setState(() {
      quantityController.text = (quantity + 1).toString();
    });
  }

  void decrease() {
    setState(() {
      if (quantity > 1) {
        quantityController.text = (quantity - 1).toString();
      }
    });
  }

  void _calculatePrice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (selectedRule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a pricing rule first"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      calculationResult = null;
    });

    final pricingRepo = context.read<PricingRepository>();
    final selectedExtrasStr = extrasCheckboxes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(',');

    try {
      final res = await pricingRepo.calculatePrice(
        pricingId: selectedRule!.id,
        weight: double.tryParse(weightController.text) ?? 0.0,
        distance: double.tryParse(distanceController.text) ?? 0.0,
        serviceType: selectedServiceType,
        selectedExtras: selectedExtrasStr,
        quantity: quantity,
      );

      if (res['success'] == true) {
        setState(() {
          final rawData = res['data'];
          if (rawData is Map && rawData.containsKey('data')) {
            calculationResult = Map<String, dynamic>.from(rawData['data']);
          } else {
            calculationResult = Map<String, dynamic>.from(rawData);
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = res['message'] ?? "Calculation failed";
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  double _getFinalPriceValue(Map<String, dynamic> data) {
    if (data.containsKey('finalPrice')) return double.tryParse(data['finalPrice'].toString()) ?? 0.0;
    if (data.containsKey('totalPrice')) return double.tryParse(data['totalPrice'].toString()) ?? 0.0;
    if (data.containsKey('total')) return double.tryParse(data['total'].toString()) ?? 0.0;
    if (data.containsKey('totalCharge')) return double.tryParse(data['totalCharge'].toString()) ?? 0.0;
    for (var entry in data.entries) {
      if (entry.key.toLowerCase().contains('total') || entry.key.toLowerCase().contains('final')) {
        return double.tryParse(entry.value.toString()) ?? 0.0;
      }
    }
    return 0.0;
  }

  Widget _buildCalculationResultWidget(BuildContext context, Map<String, dynamic> result) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Extract breakdown if present
    final breakdown = result['breakdown'] is Map ? Map<String, dynamic>.from(result['breakdown']) : null;
    final currency = result['currency']?.toString() ?? 'USD';
    
    // Format helpers
    String formatMoney(dynamic val) {
      if (val == null) return '$currency 0.00';
      final parsed = double.tryParse(val.toString()) ?? 0.0;
      return '$currency ${parsed.toStringAsFixed(2)}';
    }

    String formatKey(String key) {
      String formatted = key.replaceAll(RegExp(r'([A-Z])'), r' $1');
      return formatted[0].toUpperCase() + formatted.substring(1);
    }

    final double finalPrice = _getFinalPriceValue(result);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  result['ruleName'] ?? "Calculation Result",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result['type']?.toString().toUpperCase() ?? "CARGO",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          if (breakdown != null) ...[
            _buildBreakdownRow("Base Cost", formatMoney(breakdown['baseCost']), theme),
            _buildBreakdownRow("Weight Cost", formatMoney(breakdown['weightCost']), theme),
            _buildBreakdownRow("Distance Cost", formatMoney(breakdown['distanceCost']), theme),
            _buildBreakdownRow("Service Cost", formatMoney(breakdown['serviceCost']), theme),
            
            if (breakdown['extrasCost'] != null && breakdown['extrasCost'] != 0)
              _buildBreakdownRow("Extras Cost", formatMoney(breakdown['extrasCost']), theme),
              
            if (breakdown['appliedExtras'] is Map && (breakdown['appliedExtras'] as Map).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Column(
                  children: (breakdown['appliedExtras'] as Map).entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("• ${formatKey(e.key.toString())}:", style: TextStyle(fontSize: 12, color: theme.hintColor)),
                          Text(formatMoney(e.value), style: TextStyle(fontSize: 12, color: theme.hintColor)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            if (breakdown['minimumChargeApplied'] == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Minimum Charge Applied", style: TextStyle(fontSize: 13, color: theme.hintColor, fontStyle: FontStyle.italic)),
                    const Text("Yes", style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            _buildBreakdownRow("Tax", formatMoney(breakdown['tax']), theme),
            if (breakdown['subtotal'] != null)
              _buildBreakdownRow("Subtotal", formatMoney(breakdown['subtotal']), theme),
          ] else ...[
            ...result.entries.where((entry) {
              final k = entry.key.toLowerCase();
              return k != 'ruleName' && k != 'type' && k != 'currency' && k != 'finalprice' && k != 'totalprice' && k != 'total' && k != 'totalcharge' && entry.value is! Map && entry.value is! List;
            }).map((entry) {
              return _buildBreakdownRow(formatKey(entry.key), entry.value is num ? formatMoney(entry.value) : entry.value.toString(), theme);
            }),
          ],

          const Divider(height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Final Price:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              Text(
                formatMoney(finalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeRules = widget.rules.where((r) => r.isActive).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Price Calculator",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Calculate final price based on current rules",
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 26),

            if (activeRules.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No active pricing rules found. Please add a pricing rule first to use the calculator.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.hintColor, fontSize: 14),
                  ),
                ),
              ),
            ] else ...[
              Text(
                "Pricing Rule (Category)",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<PricingRuleMod>(
                value: selectedRule,
                isExpanded: true,
                dropdownColor: theme.cardTheme.color,
                validator: (v) => v == null ? 'Please select a rule' : null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.dividerTheme.color ?? theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.dividerTheme.color ?? theme.dividerColor),
                  ),
                ),
                items: activeRules
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.name, style: TextStyle(color: theme.colorScheme.onSurface))))
                    .toList(),
                onChanged: (newRule) {
                  if (newRule != null) {
                    setState(() {
                      selectedRule = newRule;
                      _updateRuleFields(newRule);
                    });
                  }
                },
              ),

              const SizedBox(height: 15),

              Text(
                "Weight (kg)",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: weightController,
                hintText: "0.00",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'This field is required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 15),

              Text(
                "Distance (km)",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              CustomTextfield(
                controller: distanceController,
                hintText: "10.00",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'This field is required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              // Dynamic Service Type Dropdown
              if (selectedRule != null &&
                  selectedRule!.rawConfiguration != null &&
                  selectedRule!.rawConfiguration!['serviceTypes'] is Map &&
                  (selectedRule!.rawConfiguration!['serviceTypes'] as Map).isNotEmpty) ...[
                const SizedBox(height: 15),
                Text(
                  "Service Type",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedServiceType,
                  isExpanded: true,
                  dropdownColor: theme.cardTheme.color,
                  validator: (v) => v == null ? 'Required' : null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.dividerTheme.color ?? theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.dividerTheme.color ?? theme.dividerColor),
                    ),
                  ),
                  items: (selectedRule!.rawConfiguration!['serviceTypes'] as Map)
                      .keys
                      .map((k) => DropdownMenuItem(value: k.toString(), child: Text(k.toString().toUpperCase(), style: TextStyle(color: theme.colorScheme.onSurface))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedServiceType = val;
                      });
                    }
                  },
                ),
              ],

              // Dynamic Extras Checkboxes
              if (extrasCheckboxes.isNotEmpty) ...[
                const SizedBox(height: 15),
                Text(
                  "Additional Extras",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  children: extrasCheckboxes.keys.map((key) {
                    return CheckboxListTile(
                      title: Text(key[0].toUpperCase() + key.substring(1), style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                      value: extrasCheckboxes[key],
                      activeColor: AppColor.primary,
                      onChanged: (val) {
                        setState(() {
                          extrasCheckboxes[key] = val ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 15),

              Text(
                "Quantity",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        textAlign: TextAlign.left,
                        validator: (v) => (v == null || int.tryParse(v) == null || int.parse(v) < 1) ? 'Invalid' : null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: increase,
                          child: Icon(Icons.keyboard_arrow_up, size: 18, color: theme.colorScheme.onSurface),
                        ),
                        InkWell(
                          onTap: decrease,
                          child: Icon(Icons.keyboard_arrow_down, size: 18, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              if (isLoading) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColor.primary),
                  ),
                ),
              ] else if (calculationResult != null) ...[
                _buildCalculationResultWidget(context, calculationResult!),
              ] else if (errorMessage != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              CustomButton(
                text: isLoading ? "Calculating..." : "\$ Calculate Price",
                onTap: isLoading ? () {} : _calculatePrice,
              ),
            ],
          ],
        ),
      ),
    );
  }
}