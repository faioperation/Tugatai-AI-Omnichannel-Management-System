import 'package:flutter/material.dart';

class CustomMinitextfield extends StatelessWidget {
  final String hint;
  final int? maxLines;
  final TextEditingController? controller;
  final bool obscureText;

  const CustomMinitextfield({
    super.key,
    required this.hint,
    this.maxLines,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: obscureText ? TextInputType.text : TextInputType.multiline,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}