import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/app/app_color.dart';

class CustomLeadRow extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String tagText;
  final Color tagColor;
  final String time;
  final String socialIcon;
  final String socialText;

  final String? notes;
  final Function(String)? onNavigate;

  const CustomLeadRow({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.tagText,
    required this.tagColor,
    required this.time,
    required this.socialIcon,
    required this.socialText,
    this.notes,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    if (!isDesktop) {
      return _buildMobileCard(context);
    }

    return InkWell(
      onTap: () => onNavigate?.call('Inbox'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
        ),
        child: Row(
        children: [
          // NAME
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // CONTACT (EMAIL + PHONE)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email,
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(phone,
                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),

          // SOURCE (ICON + TEXT)
          Expanded(
            flex: 2,
            child: Row(
              children: [
                SvgPicture.asset(
                  socialIcon,
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  socialText,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // STATUS (TAG)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    fontSize: 12,
                    color: tagColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // LAST CONTACT
          Expanded(
            flex: 2,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // ACTIONS (EYE ICON)
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => _showLeadDetails(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.visibility, size: 20, color: theme.textTheme.bodySmall?.color),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMobileCard(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onNavigate?.call('Inbox'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    fontSize: 11,
                    color: tagColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(email,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(phone, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   SvgPicture.asset(
                    socialIcon,
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    socialText,
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: theme.textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showLeadDetails(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.visibility, size: 20, color: theme.textTheme.bodySmall?.color),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  void _showLeadDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final width = MediaQuery.of(context).size.width;
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: theme.cardTheme.color,
          child: Container(
            width: width < 600 ? width * 0.9 : 500,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Lead Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "View and manage lead information",
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: theme.textTheme.bodySmall?.color),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Data Grid
                width < 500
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailField(context, "Name", name, isBold: true),
                          const SizedBox(height: 20),
                          _buildStatusField(context),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDetailField(context, "Name", name, isBold: true),
                          ),
                          Expanded(
                            child: _buildStatusField(context),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                width < 500
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailField(context, "Email", email),
                          const SizedBox(height: 20),
                          _buildDetailField(context, "Phone", phone),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDetailField(context, "Email", email),
                          ),
                          Expanded(
                            child: _buildDetailField(context, "Phone", phone),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                width < 500
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSourceField(context),
                          const SizedBox(height: 20),
                          _buildDetailField(context, "Last Contact", time),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildSourceField(context),
                          ),
                          Expanded(
                            child: _buildDetailField(context, "Last Contact", time),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),

                // Notes
                Text(
                  "Notes",
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notes ?? "No notes available for this lead.",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusField(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Status",
          style: TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: tagColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tagText,
            style: TextStyle(
              fontSize: 12,
              color: tagColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceField(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Source",
          style: TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            SvgPicture.asset(
              socialIcon,
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 8),
            Text(
              socialText,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailField(BuildContext context, String label, String value, {bool isBold = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}