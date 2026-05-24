import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';

import 'package:roberto/features/Pricing/widget/pricing_rule_mod.dart';

class CustomAddrule extends StatefulWidget {
  final PricingRuleMod? rule;
  final Function(PricingRuleMod)? onSave;

  const CustomAddrule({super.key, this.rule, this.onSave});

  @override
  State<CustomAddrule> createState() => _CustomAddruleState();
}

class _CustomAddruleState extends State<CustomAddrule> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.rule != null) {
      nameController.text = widget.rule!.name;
      typeController.text = widget.rule!.type;
      valueController.text = widget.rule!.value;
      isActive = widget.rule!.isActive;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    valueController.dispose();
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
        width: isDesktop ? 450 : double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(context, "Rule Name"),
              const SizedBox(height: 6),
              CustomTextfield(
                  hintText: "Enter rule name", controller: nameController),
              const SizedBox(height: 15),
              _buildLabel(context, "Rule Type"),
              const SizedBox(height: 6),
              CustomTextfield(
                  hintText: "Select type", controller: typeController),
              const SizedBox(height: 15),
              _buildLabel(context, "Value"),
              const SizedBox(height: 6),
              CustomTextfield(
                  hintText: "e.g., 15 or +20%", controller: valueController),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Active",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Transform.scale(
                    scale: isDesktop ? 0.9 : 0.8,
                    child: Switch(
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                      activeThumbColor: AppColor.greens,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 12,
        vertical: 10,
      ),
      actions: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buttons(context),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buttons(context),
              ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
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
      const SizedBox(width: 10, height: 10),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        onPressed: () {
          if (widget.onSave != null) {
            final newRule = PricingRuleMod(
              id: widget.rule?.id ?? DateTime.now().toString(),
              name: nameController.text,
              type: typeController.text,
              value: valueController.text,
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
      const SizedBox(height: 15),
    ];
  }
}