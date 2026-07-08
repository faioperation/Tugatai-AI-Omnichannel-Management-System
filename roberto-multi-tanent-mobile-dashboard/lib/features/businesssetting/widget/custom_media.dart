import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/app/app_color.dart';

class CustomMedia extends StatefulWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final VoidCallback onActionPressed;
  final bool isLoading;
  final bool isConnected;

  const CustomMedia({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.isConnected,
    required this.onActionPressed,
    this.isLoading = false,
  });

  @override
  State<CustomMedia> createState() => _CustomMediaState();
}

class _CustomMediaState extends State<CustomMedia> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      widget.iconPath,
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.isConnected) ...[
                      _buildConnectedButton(),
                      const SizedBox(width: 8),
                    ],
                    _buildActionButton(),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ICON
                SvgPicture.asset(
                  widget.iconPath,
                  height: 45,
                  width: 45,
                ),

                const SizedBox(width: 22),

                // TITLE + SUBTITLE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                // BUTTONS (same line)
                Row(
                  children: [
                    if (widget.isConnected) ...[
                      _buildConnectedButton(),
                      const SizedBox(width: 10),
                    ],
                    _buildActionButton(),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildConnectedButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.green.withOpacity(0.15) : const Color(0xffD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: isDark ? Colors.green.shade400 : const Color(0xff059669)),
          const SizedBox(width: 6),
          Text(
            'Connected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.green.shade400 : const Color(0xff059669),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.isConnected 
        ? (isDark ? Colors.red.withOpacity(0.15) : const Color(0xffFEE2E2)) 
        : (isDark ? AppColor.primary.withOpacity(0.15) : AppColor.primary.withOpacity(0.1));
    final fg = widget.isConnected ? (isDark ? Colors.red.shade300 : const Color(0xffDC2626)) : AppColor.primary;
    final text = widget.isConnected ? 'Disconnect' : 'Connect';

    return InkWell(
      onTap: widget.isLoading ? null : widget.onActionPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.isLoading 
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
            : Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
      ),
    );
  }
}