import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';

class CustomWidgetrule extends StatefulWidget {
  final String title;
  final String badgeText;
  final String description;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomWidgetrule({
    super.key,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CustomWidgetrule> createState() => _CustomWidgetruleState();
}

class _CustomWidgetruleState extends State<CustomWidgetrule> {
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: isDesktop ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: isDesktop ? null : BorderRadius.circular(12),
        border: isDesktop
            ? Border(
                bottom: BorderSide(
                    color: theme.dividerColor.withOpacity(0.1), width: 1))
            : Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      child: isDesktop
          ? Row(
              children: [
                // Title
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                // Badge
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.surface
                              : const Color(0xffF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.badgeText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Description
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                // Switch
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.scale(
                      scale: 0.75,
                      child: Switch(
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                        activeThumbColor: AppColor.greens,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ),

                // Actions
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        tooltip: "Edit",
                        onPressed: widget.onEdit,
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        tooltip: "Delete",
                        onPressed: widget.onDelete,
                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                  activeThumbColor: AppColor.greens,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : const Color(0xffF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Edit"),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete, size: 18),
                label: const Text("Delete"),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}