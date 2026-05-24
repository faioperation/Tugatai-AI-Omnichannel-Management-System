import 'package:flutter/material.dart';

class CustomMinitextfield extends StatelessWidget {
  final String hint;
  final int? maxLines;

  const CustomMinitextfield({
    super.key,
    required this.hint,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
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