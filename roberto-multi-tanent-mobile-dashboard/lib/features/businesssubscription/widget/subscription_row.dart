import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionRow extends StatelessWidget {
  final String date;
  final String plan;
  final String price;
  final String expireDate;
  final String status;
  final String subStatus;
  final String? invoiceUrl;
  final bool isMobile;

  const SubscriptionRow({
    super.key,
    required this.date,
    required this.plan,
    required this.price,
    required this.expireDate,
    required this.status,
    required this.subStatus,
    this.invoiceUrl,
    this.isMobile = false,
  });

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isUnpaid => status.toLowerCase() == 'unpaid';
  bool get isSubActive => subStatus.toUpperCase() == 'ACTIVE';

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

          // Status (Subscription) - colored badge pill
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildSubStatusPill(context),
            ),
          ),

          // Billing Status (Invoice)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusPill(context),
            ),
          ),

          // Renew/Download Button
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: isUnpaid
                  ? _buildRenewButton(context)
                  : isPaid && invoiceUrl != null && invoiceUrl!.isNotEmpty
                      ? _buildDownloadButton(context)
                      : const SizedBox.shrink(),
            ),
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
              _buildInfoColumn(context, "Status", subStatus),
              _buildInfoColumn(context, "Pricing", price),
              if (isUnpaid) _buildRenewButton(context),
              if (isPaid && invoiceUrl != null && invoiceUrl!.isNotEmpty) _buildDownloadButton(context),
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

  Widget _buildSubStatusPill(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeBg = isDark ? const Color(0xFF1B5E20).withOpacity(0.2) : const Color(0xFFE8F5E9);
    final cancelBg = isDark ? const Color(0xFFB71C1C).withOpacity(0.2) : const Color(0xFFFFEBEE);
    final pendingBg = isDark ? const Color(0xFF4A3800).withOpacity(0.3) : const Color(0xFFFFF8E1);
    final activeColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    final cancelColor = isDark ? const Color(0xFFE57373) : const Color(0xFFC62828);
    final pendingColor = isDark ? const Color(0xFFFFD54F) : const Color(0xFFE65100);

    Color bg;
    Color textColor;
    if (isSubActive) {
      bg = activeBg;
      textColor = activeColor;
    } else if (subStatus.toUpperCase() == 'CANCELED' || subStatus.toUpperCase() == 'CANCELLED') {
      bg = cancelBg;
      textColor = cancelColor;
    } else {
      bg = pendingBg;
      textColor = pendingColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        subStatus.toUpperCase() == 'ACTIVE' ? 'Active' :
        subStatus.toUpperCase() == 'CANCELED' || subStatus.toUpperCase() == 'CANCELLED' ? 'Cancelled' : subStatus,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
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

  Widget _buildDownloadButton(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        if (invoiceUrl != null && invoiceUrl!.isNotEmpty) {
          final uri = Uri.parse(invoiceUrl!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download, size: 14, color: theme.colorScheme.onSurface),
            const SizedBox(width: 4),
            Text(
              "Download",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}