import re

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'r') as f:
    content = f.read()

imports = """import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Orderbooking/bloc/booking_bloc.dart';
import 'package:roberto/features/Orderbooking/bloc/booking_event.dart';
import 'package:roberto/features/Orderbooking/bloc/booking_state.dart';
import 'package:roberto/features/Orderbooking/data/repositories/booking_repository.dart';
"""

if "import 'package:flutter_bloc/flutter_bloc.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + imports)

# We need to wrap the Scaffold/LayoutBuilder with BlocProvider if it's not wrapped yet.
# Actually, the simplest way is to fetch data in initState and use BlocBuilder in the main build.
# Wait, OrderBookingScreen currently returns LayoutBuilder directly.
# Let's change the class structure: 
# OrderBookingScreen -> returns BlocProvider(create: (_) => BookingBloc(repository: BookingRepository())..add(GetBookings(branchId: '5feaac7b-c436-4ecb-8a12-9632e4090205')), child: _OrderBookingView())
# We can just inject the BlocProvider in the build method!

# Let's add a fixed branch ID for testing
content = content.replace('class _OrderBookingScreenState extends State<OrderBookingScreen> {', '''class _OrderBookingScreenState extends State<OrderBookingScreen> {
  final String _branchId = '5feaac7b-c436-4ecb-8a12-9632e4090205';
''')

# In initState, we don't have the context for bloc yet if we provide it in build, so we provide it outside.
# Let's create a wrapper class and rename the existing OrderBookingScreen.

# 1. Rename OrderBookingScreen to OrderBookingView
content = content.replace('class OrderBookingScreen extends StatefulWidget', 'class OrderBookingView extends StatefulWidget')
content = content.replace('State<OrderBookingScreen>', 'State<OrderBookingView>')
content = content.replace('class _OrderBookingScreenState extends State<OrderBookingScreen>', 'class _OrderBookingViewState extends State<OrderBookingView>')
content = content.replace('_OrderBookingScreenState()', '_OrderBookingViewState()')

# 2. Add the real OrderBookingScreen that provides the bloc
wrapper = """
class OrderBookingScreen extends StatelessWidget {
  final Function(String)? onNavigate;
  const OrderBookingScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc(repository: BookingRepository())..add(const GetBookings(branchId: '5feaac7b-c436-4ecb-8a12-9632e4090205')),
      child: OrderBookingView(onNavigate: onNavigate),
    );
  }
}

"""
content = content.replace('class OrderBookingView extends StatefulWidget', wrapper + 'class OrderBookingView extends StatefulWidget')

# 3. Inside _OrderBookingViewState, read from BlocBuilder
# Replace `List<OrderMod> _orders = [];` with dynamic getter or just use BlocBuilder wrapping the main LayoutBuilder.

content = re.sub(r'List<OrderMod> _orders = \[\];', '', content)

build_method = """  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        List<OrderMod> _orders = [];
        bool isLoading = false;
        
        if (state is BookingLoaded) {
          _orders = state.bookings;
        } else if (state is BookingLoading) {
          isLoading = true;
        }
        
        // We will pass _orders to our existing logic.
        // Wait, the existing logic uses _filteredOrders which depends on _orders!
        // Let's define a local function or just keep _orders as a local variable.
        // The problem is _filteredOrders is a getter.
        // Let's redefine _orders as an instance variable and update it in listener/builder, or just let it read from state.
"""

# Let's fix _orders being a property.
# We will just replace `get _filteredOrders` to `List<OrderMod> _filteredOrders(List<OrderMod> _orders)` 
# Or simpler: keep `List<OrderMod> _orders = [];` but update it in the builder!

