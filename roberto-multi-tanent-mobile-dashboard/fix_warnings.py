import re

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'r') as f:
    content = f.read()

# Fix dead code and dead null aware expression
# Warning is at line 1249: o.deliveryDate != null
# We replaced o.deliveryDate with DateTime.tryParse(o.appointmentDate ?? "")
# So it becomes DateTime.tryParse(...) != null && DateTime.tryParse(...)!.year ...
# This is valid. Wait, let's see what the actual code is.

