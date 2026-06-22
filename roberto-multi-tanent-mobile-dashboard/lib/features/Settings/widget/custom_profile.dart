import 'package:flutter/material.dart';

class CustomProfile extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final bool readOnly;

  const CustomProfile({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 6),

        TextField(
          controller: controller,
          readOnly: readOnly,
          cursorColor: theme.colorScheme.primary,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 18, color: theme.iconTheme.color) : null,
            hintText: hint,
            hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),

            filled: true,
            fillColor: theme.brightness == Brightness.dark ? theme.colorScheme.surface : Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}