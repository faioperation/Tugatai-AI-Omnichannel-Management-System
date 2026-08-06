import 'package:flutter/material.dart';

class CustomMiniDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final String hint;
  final Map<String, String>? tooltips;

  const CustomMiniDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    this.tooltips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(19),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: items.map((String item) {
            final String? tooltipText = tooltips?[item];
            Widget childWidget = Text(
              item,
              style: const TextStyle(fontSize: 14),
            );
            if (tooltipText != null) {
              childWidget = Tooltip(
                message: tooltipText,
                waitDuration: const Duration(milliseconds: 300),
                child: childWidget,
              );
            }
            return DropdownMenuItem<String>(
              value: item,
              child: childWidget,
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
