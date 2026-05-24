import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';

class CustomHeadder extends StatelessWidget {
  final String label;
  final TextAlign? textAlign;
  const CustomHeadder({required this.label, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

