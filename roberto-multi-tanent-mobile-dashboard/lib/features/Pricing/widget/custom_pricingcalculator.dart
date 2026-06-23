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
          calculationResult = res['data'];
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
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      textAlign: TextAlign.left,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : const Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ...calculationResult!.entries.map((entry) {
                      final key = entry.key;
                      final val = entry.value;
                      
                      if (key.toLowerCase() == 'finalprice' || key.toLowerCase() == 'totalprice' || key.toLowerCase() == 'total' || key.toLowerCase() == 'totalcharge') {
                        return const SizedBox.shrink();
                      }
                      
                      String formattedKey = key.replaceAll(RegExp(r'([A-Z])'), r' $1');
                      formattedKey = formattedKey[0].toUpperCase() + formattedKey.substring(1);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("$formattedKey:", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                            Text(val is num ? "\$${val.toStringAsFixed(2)}" : val.toString(), style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Final Price:", style: TextStyle(
                          fontSize: 15,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        )),
                        Text(
                          "\$${_getFinalPriceValue(calculationResult!).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
    );
  }
}