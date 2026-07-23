import re

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'r') as f:
    content = f.read()

# We need to make `_orders` a field again to avoid compilation errors, and update it inside the build method.
if 'List<OrderMod> _orders = [];' not in content:
    content = content.replace('int _currentPage = 1;', 'List<OrderMod> _orders = [];\n  int _currentPage = 1;')

# Replace build method to wrap with BlocConsumer
old_build = """  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {"""

new_build = """  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        if (state is BookingLoaded) {
          _orders = state.bookings;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (state is BookingLoading && _orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
"""

content = content.replace(old_build, new_build)

# Add closing bracket for BlocConsumer
old_build_end = """        );
      },
    );
  }"""
new_build_end = """        );
          },
        );
      },
    );
  }"""

content = content.replace(old_build_end, new_build_end)

# Wire up the new booking button
content = re.sub(r'onPressed: \(\) => _openOrderDialog\(\)', 'onPressed: () => _openOrderDialog(context)', content)

# Modify _openOrderDialog
old_dialog = """  void _openOrderDialog({OrderMod? order}) {
    showDialog(
      context: context,
      builder: (context) => CreateOrderDialog(order: order),
    );
  }"""
new_dialog = """  Future<void> _openOrderDialog(BuildContext context, {OrderMod? order}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CreateOrderDialog(order: order),
    );
    if (result != null && result is Map<String, dynamic>) {
      if (order == null) {
        context.read<BookingBloc>().add(CreateBooking(payload: result, branchId: _branchId));
      } else {
        context.read<BookingBloc>().add(UpdateBooking(id: order.orderId, payload: result, branchId: _branchId));
      }
    }
  }"""
content = content.replace(old_dialog, new_dialog)

# Update Mobile edit/delete buttons
content = content.replace('_openOrderDialog(order: order)', '_openOrderDialog(context, order: order)')

# Update Desktop edit/delete buttons
old_edit_action = """onPressed: () => _openOrderDialog(order: order),"""
new_edit_action = """onPressed: () => _openOrderDialog(context, order: order),"""
content = content.replace(old_edit_action, new_edit_action)

delete_logic = """onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Delete Booking'),
                        content: const Text('Are you sure you want to delete this booking?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(c);
                              context.read<BookingBloc>().add(DeleteBooking(id: order.orderId, branchId: _branchId));
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  }"""
content = re.sub(r'onPressed: \(\) \{\},\s*icon: const Icon\(Icons\.delete_outline', delete_logic + ',\n                  icon: const Icon(Icons.delete_outline', content)
# For the widget order_row_item.dart we pass onEdit and onDelete

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'w') as f:
    f.write(content)

