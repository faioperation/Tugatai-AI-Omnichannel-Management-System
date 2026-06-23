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

    final customFieldRows = <Widget>[];
    final predefinedKeys = {
      'bookingType',
      'appointmentDate',
      'appointmentTime',
      'platform',
      'duration',
      'customRequirement',
      'pickupAddress',
      'deliveryDate',
      'deliveryAddress',
      'productType',
      'productHeight',
      'productWeight',
      'receiverPhone',
      'companyName',
      'customerName',
      'customerNumber',
      'email',
      'price',
      'note',
      'status',
      'branchId',
    };

    order.rawAdditionalDetails.forEach((key, value) {
      if (!predefinedKeys.contains(key) && key.isNotEmpty) {
        customFieldRows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(key, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                Text(value?.toString() ?? '', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13)),
              ],
            ),
          ),
        );
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.cardColor,
      child: Container(
        width: isMobile ? width * 0.95 : 480,
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
                if (order.email != null && order.email!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildIconRow(Icons.email_outlined, order.email!, theme),
                ],
              ], theme, isDark),
              const SizedBox(height: 20),

              // Booking Details Section
              _buildSectionTitle('Booking Details (${order.bookingType ?? "General"})', theme),
              const SizedBox(height: 8),
              _buildInfoContainer([
                if (order.bookingType == 'Appointment Booking') ...[
                  _buildDetailRow('Date', order.appointmentDate ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Time', order.appointmentTime ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Platform', order.platform ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Duration', order.duration ?? 'N/A', theme),
                  if (order.customRequirement != null && order.customRequirement!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('Requirement', order.customRequirement!, theme),
                  ],
                ] else if (order.bookingType == 'Parcel Delivery') ...[
                  _buildDetailRow('Pickup', order.pickupAddress ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Delivery Date', order.deliveryDate ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Delivery To', order.deliveryAddress ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Receiver Phone', order.receiverPhone ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Product Type', order.productType ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Height / Weight', '${order.productHeight ?? "N/A"} / ${order.productWeight ?? "N/A"} kg', theme),
                ] else if (order.bookingType == 'Order Booking') ...[
                  _buildDetailRow('Company', order.companyName ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Delivery Date', order.deliveryDate ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Delivery To', order.deliveryAddress ?? 'N/A', theme),
                  const SizedBox(height: 8),
                  _buildDetailRow('Product Type', order.productType ?? 'N/A', theme),
                ],
              ], theme, isDark),
              const SizedBox(height: 20),

              // Custom/Extra Fields Section
              if (customFieldRows.isNotEmpty) ...[
                _buildSectionTitle('Additional Fields', theme),
                const SizedBox(height: 8),
                _buildInfoContainer(customFieldRows, theme, isDark),
                const SizedBox(height: 20),
              ],

              // Notes Section (if note is present)
              if (order.note != null && order.note!.isNotEmpty) ...[
                _buildSectionTitle('Notes', theme),
                const SizedBox(height: 8),
                _buildInfoContainer([
                  Text(
                    order.note!,
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                  ),
                ], theme, isDark),
                const SizedBox(height: 20),
              ],

              // Payment Information
              _buildSectionTitle('Payment Details', theme),
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
              Text(
                'Order Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
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
            Text(
              'Order ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.15) : const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildPaymentContainer(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.15) : const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
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
                '\$${order.price}',
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (order.paymentMethod != null || order.paymentStatus != null || order.transactionId != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            _buildDetailRow('Method', order.paymentMethod ?? 'N/A', theme),
            const SizedBox(height: 8),
            _buildDetailRow('Status', order.paymentStatus ?? 'N/A', theme),
            const SizedBox(height: 8),
            _buildDetailRow('Txn ID', order.transactionId ?? 'N/A', theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
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
      case OrderStatus.completed:
      case OrderStatus.delivered:
        bg = isDark ? Colors.green.withOpacity(0.1) : const Color(0xffD1FAE5);
        fg = isDark ? Colors.green.shade400 : const Color(0xff059669);
        label = status == OrderStatus.completed ? 'Completed' : 'Delivered';
        break;
      case OrderStatus.cancelled:
        bg = isDark ? Colors.red.withOpacity(0.1) : const Color(0xffFEE2E2);
        fg = isDark ? Colors.red.shade400 : const Color(0xffDC2626);
        label = 'Cancelled';
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
