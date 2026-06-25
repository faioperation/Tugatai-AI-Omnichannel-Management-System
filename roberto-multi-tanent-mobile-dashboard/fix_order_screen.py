import re

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'r') as f:
    content = f.read()

# Replace dummy data with empty list for now (we'll fetch from API later)
content = re.sub(r'final List<OrderMod> _orders = \[.*?\];', 'List<OrderMod> _orders = [];', content, flags=re.DOTALL)

# Replace order.address with order.platform ?? order.source ?? "N/A"
content = re.sub(r'order\.address', 'order.platform ?? order.source ?? "N/A"', content)

# Replace order.shippingCharge with order.price
content = re.sub(r'order\.shippingCharge\.toStringAsFixed\(2\)', 'order.price', content)
content = re.sub(r'order\.shippingCharge', 'order.price', content)

# Replace order.deliveryTime with order.appointmentDate
content = re.sub(r'order\.deliveryTime', '"${order.appointmentDate ?? \'\'} ${order.appointmentTime ?? \'\'}"', content)

# Replace order.deliveryDate with order.appointmentDate parsed
content = re.sub(r'order\.deliveryDate', 'DateTime.tryParse(order.appointmentDate ?? "") ?? DateTime.now()', content)

# Replace order.productName and order.quantity
content = re.sub(r'order\.productName', 'order.note ?? "Booking"', content)
content = re.sub(r'order\.quantity\.toString\(\)', '"1"', content)
content = re.sub(r'order\.quantity', '1', content)

# Fix switch statement
old_switch = """    switch (status) {
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
    }"""
new_switch = """    switch (status) {
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
    }"""
content = content.replace(old_switch, new_switch)

# Fix order.copyWith
content = re.sub(r'order\.copyWith\([^)]+\)', 'order /* copyWith removed */', content)

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'w') as f:
    f.write(content)

