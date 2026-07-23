import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String iconPath; // SVG path


  const CustomStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 30,
                height: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}