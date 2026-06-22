import 'package:flutter/material.dart';

class CustomHeadder extends StatelessWidget {
  final String label;
  final TextAlign? textAlign;
  const CustomHeadder({
    super.key,
    required this.label,
    this.textAlign = TextAlign.left,
  });

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

