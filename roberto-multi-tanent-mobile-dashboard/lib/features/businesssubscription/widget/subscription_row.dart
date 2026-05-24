import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';

class SubscriptionRow extends StatelessWidget {
  final String date;
  final String plan;
  final String price;
  final String expireDate;
  final String status;
  final bool isMobile;

  const SubscriptionRow({
    super.key,
    required this.date,
    required this.plan,
    required this.price,
    required this.expireDate,
    required this.status,
    this.isMobile = false,
  });

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isUnpaid => status.toLowerCase() == 'unpaid';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isMobile) {
      return _buildMobileCard(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),

          // Plan
          Expanded(
            flex: 2,
            child: Text(
              plan,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),

          // Pricing
          Expanded(
            flex: 2,
            child: Text(
              price,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),

          // Expire Date
          Expanded(
            flex: 2,
            child: Text(
              expireDate,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusPill(context),
            ),
          ),

          // Renew Button (ONLY for unpaid)
          Expanded(
            flex: 2,
            child: isUnpaid
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: _buildRenewButton(context),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              _buildStatusPill(context),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(context, "Date", date),
              _buildInfoColumn(context, "Expire Date", expireDate),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildInfoColumn(context, "Pricing", price),
              if (isUnpaid) _buildRenewButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildStatusPill(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final activeBg = isDark ? const Color(0xFF1B5E20).withOpacity(0.2) : const Color(0xFFE8F5E9);
    final errorBg = isDark ? const Color(0xFFB71C1C).withOpacity(0.2) : const Color(0xFFFFEBEE);
    final activeColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    final errorColor = isDark ? const Color(0xFFE57373) : const Color(0xFFC62828);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid ? activeBg : errorBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isPaid ? activeColor : errorColor).withOpacity(0.5),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isPaid ? activeColor : errorColor,
        ),
      ),
    );
  }

  Widget _buildRenewButton(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        print("Renew Now clicked");
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: theme.dividerTheme.color ?? const Color(0xffEEEEEE),
            width: 1,
          ),
        ),
        child: Text(
          "Renew Now",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}