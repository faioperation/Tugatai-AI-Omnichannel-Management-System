import re

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'r') as f:
    content = f.read()

# Fix o.deliveryDate
content = re.sub(r'o\.deliveryDate', 'DateTime.tryParse(o.appointmentDate ?? "")', content)

# Fix _updateOrderStatus
old_update = """  void _updateOrderStatus(String orderId, OrderStatus newStatus) {
    setState(() {
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
      }
    });
  }"""
new_update = """  void _updateOrderStatus(String orderId, OrderStatus newStatus) {
    // Determine string status
    String statusStr = 'PENDING';
    if (newStatus == OrderStatus.confirmed) statusStr = 'CONFIRMED';
    else if (newStatus == OrderStatus.completed) statusStr = 'COMPLETED';
    else if (newStatus == OrderStatus.delivered) statusStr = 'DELIVERED';
    else if (newStatus == OrderStatus.cancelled) statusStr = 'CANCELLED';
    
    context.read<BookingBloc>().add(UpdateBooking(id: orderId, payload: {'status': statusStr}, branchId: _branchId));
  }"""
content = content.replace(old_update, new_update)

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'w') as f:
    f.write(content)

