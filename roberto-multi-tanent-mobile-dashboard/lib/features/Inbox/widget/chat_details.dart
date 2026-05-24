import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';

class ChatDetails extends StatelessWidget {
  const ChatDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      color: theme.cardTheme.color,
      child: Column(
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mrs Sarah",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "+992371836",
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "cold",
                    style: TextStyle(
                      color: isDark ? theme.colorScheme.onSecondary : AppColor.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Chat summary card
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerTheme.color ?? (isDark ? AppColor.borderDark : AppColor.borderLight)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(11),
                          ),
                        ),
                        child: const Text(
                          "Chat summary",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Customer booked a uganda pickup in Kampala for 30 kg of clothes to be collected Sunday 2026-04-08 around 9:20; location pin and item list were provided, rate explained (16 QAR/kg with a 30 kg minimum) driver will call before arrival.",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recent Chat Details form
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerTheme.color ?? (isDark ? AppColor.borderDark : AppColor.borderLight)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(11),
                          ),
                        ),
                        child: const Text(
                          "Recent Chat Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildFormField(context, "Items", "Clothes"),
                            const SizedBox(height: 16),
                            _buildFormField(context, "Pickup Area", "Banasreee, Dhaka, Bangladesh"),
                            const SizedBox(height: 16),
                            _buildFormField(context, "Destination", "Uganda, Kampala"),
                            const SizedBox(height: 16),
                            _buildFormField(context, "Weight", "16 kg"),
                            const SizedBox(height: 16),
                            _buildFormField(context, "Pickup Date & Time", "Sunday, April 5, 2026 at 9:00 AM"),
                            const SizedBox(height: 16),
                            _buildFormField(context, "Current status", "pending"),
                            const SizedBox(height: 16),
                            _buildFormField(context, "Recent summary", "summary...."),
                            const SizedBox(height: 16),
                            _buildFormField(context, "Booking info", "informa......"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerTheme.color ?? Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: theme.cardTheme.color,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}
