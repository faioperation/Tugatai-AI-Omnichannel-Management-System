import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';
import 'dart:convert';
import 'package:roberto/features/Pricing/widget/pricing_rule_mod.dart';

class CustomAddrule extends StatefulWidget {
  final PricingRuleMod? rule;
  final Function(PricingRuleMod)? onSave;

  const CustomAddrule({super.key, this.rule, this.onSave});

  @override
  State<CustomAddrule> createState() => _CustomAddruleState();
}

class _CustomAddruleState extends State<CustomAddrule> {
  // Basic
  final TextEditingController nameController = TextEditingController();
  String selectedType = 'CARGO';
  bool isActive = true;

  // Configuration
  String selectedCurrency = 'USD';
  final TextEditingController minimumChargeController = TextEditingController();

  // Weight
  bool weightEnabled = true;
  String selectedWeightUnit = 'kg';
  final TextEditingController weightRateController = TextEditingController();

  // Distance
  bool distanceEnabled = true;
  String selectedDistanceUnit = 'km';
  final TextEditingController distanceRateController = TextEditingController();

  // Service Types
  final TextEditingController standardMultiplierController = TextEditingController();
  final TextEditingController expressMultiplierController = TextEditingController();
  final TextEditingController sameDayMultiplierController = TextEditingController();

  // Additional Charges
  final TextEditingController fragileChargeController = TextEditingController();
  final TextEditingController insuranceChargeController = TextEditingController();
  final TextEditingController customsChargeController = TextEditingController();
  final TextEditingController handlingChargeController = TextEditingController();

  // Tax
  bool taxEnabled = true;
  final TextEditingController taxPercentageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.rule != null) {
      nameController.text = widget.rule!.name;
      selectedType = ['CARGO', 'SHIPPING', 'DELIVERY'].contains(widget.rule!.type.toUpperCase()) 
          ? widget.rule!.type.toUpperCase() 
          : 'CARGO';
      isActive = widget.rule!.isActive;

      final config = widget.rule!.rawConfiguration;
      if (config != null) {
        selectedCurrency = ['USD', 'EUR', 'BDT', 'INR', 'GBP'].contains(config['currency']?.toString().toUpperCase()) 
            ? config['currency'].toString().toUpperCase() 
            : 'USD';
        minimumChargeController.text = config['minimumCharge']?.toString() ?? '';
        
        if (config['weight'] is Map) {
          weightEnabled = config['weight']['enabled'] ?? true;
          selectedWeightUnit = config['weight']['unit']?.toString() ?? 'kg';
          weightRateController.text = config['weight']['rate']?.toString() ?? '';
        }
        
        if (config['distance'] is Map) {
          distanceEnabled = config['distance']['enabled'] ?? true;
          selectedDistanceUnit = config['distance']['unit']?.toString() ?? 'km';
          distanceRateController.text = config['distance']['rate']?.toString() ?? '';
        }

        if (config['serviceTypes'] is Map) {
          standardMultiplierController.text = config['serviceTypes']['standard']?['multiplier']?.toString() ?? '';
          expressMultiplierController.text = config['serviceTypes']['express']?['multiplier']?.toString() ?? '';
          sameDayMultiplierController.text = config['serviceTypes']['sameDay']?['multiplier']?.toString() ?? '';
        }
        
        if (config['additionalCharges'] is Map) {
          fragileChargeController.text = config['additionalCharges']['fragile']?.toString() ?? '';
          insuranceChargeController.text = config['additionalCharges']['insurance']?.toString() ?? '';
          customsChargeController.text = config['additionalCharges']['customs']?.toString() ?? '';
          handlingChargeController.text = config['additionalCharges']['handling']?.toString() ?? '';
        }
        
        if (config['tax'] is Map) {
          taxEnabled = config['tax']['enabled'] ?? true;
          taxPercentageController.text = config['tax']['percentage']?.toString() ?? '';
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    minimumChargeController.dispose();
    weightRateController.dispose();
    distanceRateController.dispose();
    standardMultiplierController.dispose();
    expressMultiplierController.dispose();
    sameDayMultiplierController.dispose();
    fragileChargeController.dispose();
    insuranceChargeController.dispose();
    customsChargeController.dispose();
    handlingChargeController.dispose();
    taxPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;
    final theme = Theme.of(context);
    final isEdit = widget.rule != null;

    return AlertDialog(
      backgroundColor: theme.cardTheme.color,
      surfaceTintColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 20,
      ),
      titlePadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 16,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? "Edit Pricing Rule" : "Add Pricing Rule",
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 16,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Icon(Icons.close,
                    size: 20, color: theme.textTheme.bodySmall?.color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isEdit ? "Modify the pricing rule details" : "Create a new pricing rule",
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: isDesktop ? 550 : double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Basic Info"),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, "Rule Name"),
                        const SizedBox(height: 6),
                        CustomTextfield(hintText: "Enter rule name", controller: nameController),
                        _buildHelpText("A unique identifier for this rule"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildDropdown(
                      "Rule Type",
                      selectedType,
                      ['CARGO', 'SHIPPING', 'DELIVERY'],
                      (val) => setState(() => selectedType = val!),
                      helpText: "Category of service",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDropdown(
                      "Currency",
                      selectedCurrency,
                      ['USD', 'EUR', 'BDT', 'INR', 'GBP'],
                      (val) => setState(() => selectedCurrency = val!),
                      helpText: "Transaction currency",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, "Minimum Charge"),
                        const SizedBox(height: 6),
                        CustomTextfield(hintText: "e.g. 30", controller: minimumChargeController),
                        _buildHelpText("Base price applied to any order"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel(context, "Active Status"),
                  Switch(
                    value: isActive,
                    onChanged: (val) => setState(() => isActive = val),
                    activeThumbColor: AppColor.greens,
                  ),
                ],
              ),
              
              const Divider(height: 30),
              
              _buildSectionTitle("Weight Configuration"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel(context, "Enable weight-based pricing"),
                  Switch(
                    value: weightEnabled,
                    onChanged: (val) => setState(() => weightEnabled = val),
                    activeThumbColor: AppColor.greens,
                  ),
                ],
              ),
              if (weightEnabled) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        "Weight Unit",
                        selectedWeightUnit,
                        ['kg', 'g', 'lb', 'oz'],
                        (val) => setState(() => selectedWeightUnit = val!),
                        helpText: "Measurement unit",
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(context, "Rate per Unit"),
                          const SizedBox(height: 6),
                          CustomTextfield(hintText: "e.g. 5.0", controller: weightRateController),
                          _buildHelpText("Added cost per weight unit"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              
              const Divider(height: 30),
              
              _buildSectionTitle("Distance Configuration"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel(context, "Enable distance-based pricing"),
                  Switch(
                    value: distanceEnabled,
                    onChanged: (val) => setState(() => distanceEnabled = val),
                    activeThumbColor: AppColor.greens,
                  ),
                ],
              ),
              if (distanceEnabled) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        "Distance Unit",
                        selectedDistanceUnit,
                        ['km', 'mi', 'm'],
                        (val) => setState(() => selectedDistanceUnit = val!),
                        helpText: "Measurement unit",
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(context, "Rate per Unit"),
                          const SizedBox(height: 6),
                          CustomTextfield(hintText: "e.g. 0.2", controller: distanceRateController),
                          _buildHelpText("Added cost per distance unit"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              
              const Divider(height: 30),
              
              _buildSectionTitle("Service Multipliers"),
              Text(
                "Multiplies the base rate depending on the delivery speed.",
                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 10),
              _buildRowFields("Standard (e.g. 1.0)", standardMultiplierController, "Express (e.g. 1.5)", expressMultiplierController),
              const SizedBox(height: 10),
              _buildRowFields("Same Day (e.g. 2.0)", sameDayMultiplierController, null, null),

              const Divider(height: 30),
              
              _buildSectionTitle("Additional Fixed Charges"),
              Text(
                "Extra fixed fees added to specific order types.",
                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 10),
              _buildRowFields("Fragile items", fragileChargeController, "Insurance", insuranceChargeController),
              const SizedBox(height: 10),
              _buildRowFields("Customs fee", customsChargeController, "Handling fee", handlingChargeController),
              
              const Divider(height: 30),
              
              _buildSectionTitle("Tax Configuration"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel(context, "Apply tax to order"),
                  Switch(
                    value: taxEnabled,
                    onChanged: (val) => setState(() => taxEnabled = val),
                    activeThumbColor: AppColor.greens,
                  ),
                ],
              ),
              if (taxEnabled) ...[
                const SizedBox(height: 10),
                _buildRowFields("Tax Percentage (%)", taxPercentageController, null, null),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 12,
        vertical: 10,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _buttons(context),
        )
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, void Function(String?) onChanged, {String? helpText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, label),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).cardTheme.color,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (helpText != null) _buildHelpText(helpText),
      ],
    );
  }

  Widget _buildHelpText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildRowFields(String label1, TextEditingController ctrl1, String? label2, TextEditingController? ctrl2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(context, label1),
              const SizedBox(height: 6),
              CustomTextfield(hintText: "Enter value", controller: ctrl1),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: label2 != null && ctrl2 != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, label2),
                    const SizedBox(height: 6),
                    CustomTextfield(hintText: "Enter value", controller: ctrl2),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  List<Widget> _buttons(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.rule != null;
    return [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.brightness == Brightness.light
              ? Colors.grey.shade100
              : theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          "Cancel",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        onPressed: () {
          if (widget.onSave != null) {
            final configMap = {
              "currency": selectedCurrency,
              "minimumCharge": double.tryParse(minimumChargeController.text) ?? 0,
              "weight": {
                "enabled": weightEnabled,
                "unit": selectedWeightUnit,
                "rate": double.tryParse(weightRateController.text) ?? 0,
              },
              "distance": {
                "enabled": distanceEnabled,
                "unit": selectedDistanceUnit,
                "rate": double.tryParse(distanceRateController.text) ?? 0,
              },
              "serviceTypes": {
                "standard": {"multiplier": double.tryParse(standardMultiplierController.text) ?? 1},
                "express": {"multiplier": double.tryParse(expressMultiplierController.text) ?? 1},
                "sameDay": {"multiplier": double.tryParse(sameDayMultiplierController.text) ?? 1},
              },
              "additionalCharges": {
                "fragile": double.tryParse(fragileChargeController.text) ?? 0,
                "insurance": double.tryParse(insuranceChargeController.text) ?? 0,
                "customs": double.tryParse(customsChargeController.text) ?? 0,
                "handling": double.tryParse(handlingChargeController.text) ?? 0,
              },
              "tax": {
                "enabled": taxEnabled,
                "percentage": double.tryParse(taxPercentageController.text) ?? 0,
              }
            };

            final newRule = PricingRuleMod(
              id: widget.rule?.id ?? DateTime.now().toString(),
              name: nameController.text,
              type: selectedType,
              value: jsonEncode(configMap),
              isActive: isActive,
            );
            widget.onSave!(newRule);
          }
          Navigator.pop(context);
        },
        child: Text(
          isEdit ? "Update Rule" : "Add Rule",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ];
  }
}