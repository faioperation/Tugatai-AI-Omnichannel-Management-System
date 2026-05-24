import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/app_color.dart';

class SidebarItem extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    this.iconPath,
    this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : assert(iconPath != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColor.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (iconPath != null)
                SvgPicture.asset(
                  iconPath!,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xff6B7280),
                    BlendMode.srcIn,
                  ),
                )
              else if (icon != null)
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xff6B7280),
                ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}