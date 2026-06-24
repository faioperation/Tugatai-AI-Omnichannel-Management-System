import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';

class CustomOrders extends StatelessWidget {
  const CustomOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  //  NOW OUTSIDE BUILD (FIXED)
  void showUpdateStatusDialog({
    required BuildContext context,
    required OrderMod order,
    required void Function(OrderStatus newStatus) onUpdate,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        OrderStatus selectedStatus = order.status;
        final TextEditingController notesController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return Dialog(
              backgroundColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColor.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Update Order Status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Update the delivery status for order ${order.orderId}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ORDER INFO
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : theme.colorScheme.primaryContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDialogInfoRow('Order ID:', order.orderId),
                          const SizedBox(height: 8),
                          _buildDialogInfoRow(
                              'Customer:', order.customerName),
                          const SizedBox(height: 8),
                          _buildDialogStatusRow(
                              'Current Status:', order.status),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'New Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<OrderStatus>(
                          value: selectedStatus,
                          isExpanded: true,
                          items: OrderStatus.values.map((status) {
                            final label = status.name[0].toUpperCase() +
                                status.name.substring(1);

                            return DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Icon(
                                    status == OrderStatus.confirmed
                                        ? Icons.check_circle_outline
                                        : status == OrderStatus.delivered
                                        ? Icons.check_circle
                                        : Icons.access_time,
                                    size: 16,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    label,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() {
                                selectedStatus = v;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any notes about this update...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                          BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                          BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : theme.colorScheme.errorContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Customer will be notified that their order is confirmed and on the way.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark ? theme.colorScheme.error : const Color(0xffBE123C),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            onUpdate(selectedStatus);
                            Navigator.pop(dialogContext);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Confirm Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(value),
      ],
    );
  }

  Widget _buildDialogStatusRow(String title, OrderStatus status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(status.name),
      ],
    );
  }
}