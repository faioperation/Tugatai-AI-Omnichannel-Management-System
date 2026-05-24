import 'package:flutter/material.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';

class OrderRowItem extends StatelessWidget {
  final OrderMod order;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const OrderRowItem({
    super.key,
    required this.order,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Order ID
          Expanded(
            flex: 2,
            child: Text(
              order.orderId,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          
          // Customer
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: order.avatarColor.withOpacity(0.1),
                  child: Text(
                    order.avatarInitials,
                    style: TextStyle(
                      color: order.avatarColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        order.phone,
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
          ),
          
          // Address
          Expanded(
            flex: 2,
            child: Text(
              order.address,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          
          // Status
          Expanded(
            flex: 2,
            child: _buildStatusBadge(context, order.status),
          ),
          
          // Shipping Charge
          Expanded(
            flex: 2,
            child: Text(
              '\$${order.shippingCharge.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          
          // Delivery Time
          Expanded(
            flex: 2,
            child: Text(
              order.deliveryTime,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  color: Colors.blue.shade400,
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: Colors.green.shade400,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.red.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = isDark ? Colors.amber.withOpacity(0.1) : const Color(0xffFEF3C7);
        textColor = isDark ? Colors.amber.shade400 : const Color(0xffD97706);
        statusText = 'Pending';
        break;
      case OrderStatus.confirmed:
        backgroundColor = isDark ? Colors.blue.withOpacity(0.1) : const Color(0xffDBEAFE);
        textColor = isDark ? Colors.blue.shade400 : const Color(0xff2563EB);
        statusText = 'Confirmed';
        break;
      case OrderStatus.delivered:
        backgroundColor = isDark ? Colors.green.withOpacity(0.1) : const Color(0xffD1FAE5);
        textColor = isDark ? Colors.green.shade400 : const Color(0xff059669);
        statusText = 'Delivered';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
