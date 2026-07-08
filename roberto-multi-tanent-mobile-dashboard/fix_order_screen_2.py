import re

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'r') as f:
    content = f.read()

content = re.sub(r'order\.deliveryDate', 'DateTime.tryParse(order.appointmentDate ?? "") ?? DateTime.now()', content)
content = re.sub(r'order\.copyWith\([^)]+\)', 'order', content)

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'w') as f:
    f.write(content)

