import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/custom_pagination.dart';

class DemoBookingScreen extends StatefulWidget {
  const DemoBookingScreen({super.key});

  @override
  State<DemoBookingScreen> createState() => _DemoBookingScreenState();
}

class _DemoBookingScreenState extends State<DemoBookingScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  final List<Map<String, String>> _allBookings = List.generate(25, (index) => {
    "email": "user${index + 1}@example.com",
    "mobile": "+880 1712 XXX ${100 + index}",
    "date": "2024-04-${(index % 25) + 1}",
    "status": index % 3 == 0 ? "Called" : "Pending",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Pagination logic
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = startIndex + _itemsPerPage;
    final List<Map<String, String>> paginatedBookings = _allBookings.sublist(
      startIndex,
      endIndex > _allBookings.length ? _allBookings.length : endIndex,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Demo Booking Applications",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Manage leads from landing page demo requests",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 24),
        
        // Table Container
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(theme),
              // Body
              ...paginatedBookings.map((booking) => _buildRow(booking, theme)),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Pagination
        CustomPagination(
          totalItems: _allBookings.length,
          itemsPerPage: _itemsPerPage,
          currentPage: _currentPage,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1), // safer than surfaceContainerHighest
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, String> booking, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? Colors.transparent)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(booking["email"]!, style: const TextStyle(fontSize: 14))),
          Expanded(flex: 2, child: Text(booking["mobile"]!, style: const TextStyle(fontSize: 14))),
          Expanded(flex: 1, child: Text(booking["date"]!, style: const TextStyle(fontSize: 14))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: booking["status"] == "Called" 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                booking["status"]!,
                style: TextStyle(
                  fontSize: 12,
                  color: booking["status"] == "Called" ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Credentials sent to ${booking['email']}")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Send",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
