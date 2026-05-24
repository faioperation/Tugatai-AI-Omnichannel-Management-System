import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';

class CustomViewdetails extends StatelessWidget {
  final OrderMod order;
  final VoidCallback? onUpdatePressed;

  const CustomViewdetails({Key? key, required this.order, this.onUpdatePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.cardColor,
      child: Container(
        width: isMobile ? width * 0.9 : 450,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, theme),
              const SizedBox(height: 24),

              // Order ID
              _buildOrderIdSection(context, theme),
              const SizedBox(height: 20),

              // Customer Information
              _buildSectionTitle('Customer Information', theme),
              const SizedBox(height: 8),
              _buildInfoContainer([
                _buildIconRow(Icons.person_outline, order.customerName, theme),
                const SizedBox(height: 12),
                _buildIconRow(Icons.phone_outlined, order.phone, theme),
                const SizedBox(height: 12),
                _buildIconRow(Icons.location_on_outlined, order.address, theme),
              ], theme, isDark),
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // Payment Information
              _buildSectionTitle('Payment', theme),
              const SizedBox(height: 8),
              _buildPaymentContainer(theme, isDark),
              const SizedBox(height: 24),

              // Buttons
              _buildActionButtons(context, width, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete information about this order',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.hintColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: theme.hintColor, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildOrderIdSection(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              order.orderId,
              style: TextStyle(
                fontSize: 14,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        _buildStatusBadge(context, order.status),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInfoContainer(List<Widget> children, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.15) : const Color(0xffFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.1)) : null,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPaymentContainer(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.15) : const Color(0xffFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.1)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text('Total Amount',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14)),
            ],
          ),
          Text(
            '\$${order.shippingCharge.toStringAsFixed(2)}',
            style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, double width, ThemeData theme) {
    final bool isStack = width < 400;

    final updateBtn = ElevatedButton(
      onPressed: () {
        Navigator.pop(context); // Close view details
        if (onUpdatePressed != null) {
          onUpdatePressed!();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: const Center(
        child: Text('Update Status',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );

    final printBtn = OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Center(
        child: Text('Print Invoice',
            style: TextStyle(
                color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
    );

    if (isStack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          updateBtn,
          const SizedBox(height: 12),
          printBtn,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: updateBtn),
        const SizedBox(width: 12),
        Expanded(child: printBtn),
      ],
    );
  }

  Widget _buildIconRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    late Color bg, fg;
    late String label;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case OrderStatus.pending:
        bg = isDark ? Colors.amber.withOpacity(0.1) : const Color(0xffFEF3C7);
        fg = isDark ? Colors.amber.shade400 : const Color(0xffD97706);
        label = 'Pending';
        break;
      case OrderStatus.confirmed:
        bg = isDark ? Colors.blue.withOpacity(0.1) : const Color(0xffDBEAFE);
        fg = isDark ? Colors.blue.shade400 : const Color(0xff2563EB);
        label = 'Confirmed';
        break;
      case OrderStatus.delivered:
        bg = isDark ? Colors.green.withOpacity(0.1) : const Color(0xffD1FAE5);
        fg = isDark ? Colors.green.shade400 : const Color(0xff059669);
        label = 'Delivered';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
