import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/custom_pagination.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/DemoBooking/bloc/demo_booking_bloc.dart';
import 'package:roberto/features/DemoBooking/bloc/demo_booking_event.dart';
import 'package:roberto/features/DemoBooking/bloc/demo_booking_state.dart';
import 'package:roberto/features/DemoBooking/data/models/demo_booking_model.dart';
import 'package:roberto/features/TenantManagement/widget/custom_headder.dart';
import 'package:roberto/features/DemoBooking/data/repositories/demo_booking_repository.dart';

class DemoBookingScreen extends StatelessWidget {
  const DemoBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DemoBookingBloc(
        repository: DemoBookingRepository(
          networkClient: context.read<NetworkClient>(),
        ),
      )..add(const FetchDemoBookings()),
      child: const DemoBookingView(),
    );
  }
}

class DemoBookingView extends StatefulWidget {
  const DemoBookingView({super.key});

  @override
  State<DemoBookingView> createState() => _DemoBookingViewState();
}

class _DemoBookingViewState extends State<DemoBookingView> {
  int _currentPage = 1;
  final int _itemsPerPage = 10; // Set to 10 as per API response limit

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<DemoBookingBloc, DemoBookingState>(
          listenWhen: (previous, current) => current is DemoBookingActionSuccess || current is DemoBookingActionError,
          listener: (context, state) {
            if (state is DemoBookingActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is DemoBookingActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ],
      child: Column(
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
          
          BlocBuilder<DemoBookingBloc, DemoBookingState>(
            buildWhen: (previous, current) => current is DemoBookingLoading || current is DemoBookingLoaded || current is DemoBookingError,
            builder: (context, state) {
              if (state is DemoBookingLoading) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ));
              }
              
              if (state is DemoBookingError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              }
              
              if (state is DemoBookingLoaded) {
                final bookings = state.bookings;
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
                      ),
                      child: Column(
                        children: [
                          _buildTableHeader(theme),
                          if (bookings.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(child: Text("No demo bookings found")),
                            )
                          else
                            ...bookings.map((booking) => _buildRow(booking, theme)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomPagination(
                      totalItems: state.totalPages * _itemsPerPage, // Fake total items for custom pagination since it usually takes total count
                      itemsPerPage: _itemsPerPage,
                      currentPage: state.currentPage,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                        context.read<DemoBookingBloc>().add(FetchDemoBookings(page: page, limit: _itemsPerPage));
                      },
                    ),
                  ],
                );
              }
              
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? theme.colorScheme.surface : AppColor.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: CustomHeadder(label: 'Name')),
          Expanded(flex: 2, child: CustomHeadder(label: 'Email Address')),
          Expanded(flex: 1, child: CustomHeadder(label: 'Date')),
          Expanded(flex: 1, child: CustomHeadder(label: 'Status')),
          Expanded(flex: 2, child: CustomHeadder(label: 'Action', textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildRow(DemoBookingModel booking, ThemeData theme) {
    final bool isCalled = booking.status == "CALLED";
    final dateStr = booking.createdAt != null 
        ? "${booking.createdAt!.year}-${booking.createdAt!.month.toString().padLeft(2, '0')}-${booking.createdAt!.day.toString().padLeft(2, '0')}"
        : "N/A";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(booking.name ?? 'Unknown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface))),
          Expanded(flex: 2, child: Text(booking.email ?? 'Unknown', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface))),
          Expanded(flex: 1, child: Text(dateStr, style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color))),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCalled 
                      ? Colors.green.withValues(alpha: 0.1) 
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  booking.status ?? 'PENDING',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCalled ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'View Details',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: Icon(Icons.remove_red_eye, color: theme.textTheme.bodySmall?.color, size: 20),
                  onPressed: () {
                    _showDetailsDialog(context, booking);
                  },
                ),
                IconButton(
                  tooltip: 'Update Status',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () {
                    _showUpdateStatusDialog(context, booking);
                  },
                ),
                IconButton(
                  tooltip: 'Delete',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    _showDeleteConfirm(context, booking.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Demo Booking"),
        content: const Text("Are you sure you want to delete this demo booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DemoBookingBloc>().add(DeleteDemoBooking(id));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, DemoBookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 500, // appropriate width for details
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Demo Booking Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const Text(
                'View lead information and requirements',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 24),

              // Grid fields
              _buildDetailFieldRow('Name', booking.name ?? 'N/A', 'Email', booking.email ?? 'N/A'),
              const SizedBox(height: 16),
              
              // Full width fields for Subject and Description
              _buildFullWidthField('Subject', booking.subject ?? 'N/A'),
              const SizedBox(height: 16),
              _buildFullWidthField('Description', booking.description ?? 'N/A'),
              const SizedBox(height: 16),

              // Status and Dates
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: booking.status == 'CALLED' ? Colors.green.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: booking.status == 'CALLED' ? Colors.green.shade200 : Colors.orange.shade200),
                          ),
                          child: Text(
                            booking.status ?? 'PENDING',
                            style: TextStyle(fontSize: 12, color: booking.status == 'CALLED' ? Colors.green.shade700 : Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildField('Created At', booking.createdAt != null 
                        ? "${booking.createdAt!.year}-${booking.createdAt!.month.toString().padLeft(2, '0')}-${booking.createdAt!.day.toString().padLeft(2, '0')}"
                        : "N/A"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailFieldRow(String l1, String v1, String l2, String v2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildField(l1, v1)),
        Expanded(child: _buildField(l2, v2)),
      ],
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFullWidthField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showUpdateStatusDialog(BuildContext context, DemoBookingModel booking) {
    String selectedStatus = booking.status == 'CALLED' ? 'CALLED' : 'PENDING';
    
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Update Status",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text("Select new status:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                        DropdownMenuItem(value: 'CALLED', child: Text('CALLED')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedStatus = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            if (selectedStatus != booking.status) {
                              context.read<DemoBookingBloc>().add(UpdateDemoBookingStatus(booking.id, selectedStatus));
                            }
                          },
                          child: const Text("Update", style: TextStyle(color: Colors.white)),
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
}
