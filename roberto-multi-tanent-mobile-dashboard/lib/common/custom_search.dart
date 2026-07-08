import 'package:flutter/material.dart';

class CustomSearch extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const CustomSearch({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 40,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.dividerTheme.color ??
                (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted?.call(),
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: Icon(
              Icons.search,
              color: theme.textTheme.bodySmall?.color ?? Colors.grey,
              size: 20,
            ),
            hintText: "Search...",
            hintStyle: TextStyle(
              color: theme.textTheme.bodySmall?.color ?? Colors.grey,
              fontSize: 14,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 0,
            ),
          ),
        ),
      ),
    );
  }
}