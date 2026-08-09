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
              final isDark = Theme.of(context).brightness == Brightness.dark;
              childWidget = Tooltip(
                richMessage: WidgetSpan(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      tooltipText,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                waitDuration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(left: 120),
                preferBelow: false,
                verticalOffset: 0,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
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
