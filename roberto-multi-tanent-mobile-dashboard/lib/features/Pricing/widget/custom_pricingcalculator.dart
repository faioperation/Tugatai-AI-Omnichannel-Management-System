import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/custom_button.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';

class CustomPricingcalculator extends StatefulWidget {
  const CustomPricingcalculator({super.key});

  @override
  State<CustomPricingcalculator> createState() => _CustomPricingcalculatorState();
}

class _CustomPricingcalculatorState extends State<CustomPricingcalculator> {
  final TextEditingController quantityController =
  TextEditingController(text: "1");

  int get quantity => int.tryParse(quantityController.text) ?? 1;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

          Text(
            "Product category",
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const CustomTextfield(hintText: "Select Category"),

          const SizedBox(height: 15),

          Text(
            "Weight (kg)",
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const CustomTextfield(hintText: "0.00"),

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

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : const Color(0xffF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Base Price:", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                    Text("\$150", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Category Markup:", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                    Text("+\$30.00", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delivery Charge:", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                    Text("+\$27", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Final Price:", style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )),
                    Text("\$153.00", style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          CustomButton(text: "\$ Calculate Price", onTap: (){})

        ],
      ),
    );
  }
}