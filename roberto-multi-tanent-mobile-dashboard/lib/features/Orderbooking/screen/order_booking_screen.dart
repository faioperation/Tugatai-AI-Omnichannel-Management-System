import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/TenantManagement/widget/custom_stat_card.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';
import 'package:roberto/features/Orderbooking/widget/custom_orders.dart';
import 'package:roberto/features/Orderbooking/widget/custom_viewdetails.dart';
import 'package:roberto/features/TenantManagement/widget/custom_headder.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:roberto/features/Orderbooking/widget/create_order_dialog.dart';
import 'package:roberto/features/Orderbooking/widget/create_google_event_dialog.dart';
import 'package:roberto/common/custom_pagination.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Settings/bloc/profile_bloc.dart';
import 'package:roberto/features/Settings/bloc/profile_state.dart';
import 'package:roberto/features/Orderbooking/bloc/booking_bloc.dart';
import 'package:roberto/features/Orderbooking/bloc/booking_event.dart';
import 'package:roberto/features/Orderbooking/bloc/booking_state.dart';
import 'package:url_launcher/url_launcher.dart';

// Breakpoint
const double _kDesktop = 700;

class OrderBookingScreen extends StatefulWidget {
  final void Function(String, {String? targetPhone, String? conversationId})? onNavigate;
  final String? branchId;
  const OrderBookingScreen({super.key, this.onNavigate, this.branchId});

  @override
  State<OrderBookingScreen> createState() => _OrderBookingScreenState();
}

class _OrderBookingScreenState extends State<OrderBookingScreen> {

  String _getBranchId() {
    return widget.branchId ?? '';
  }

  Future<void> _checkGoogleCalendarStatus() async {
    final branchId = _getBranchId();
    if (branchId.isEmpty) return;

    setState(() {
      _isLoadingCalendarStatus = true;
    });

    try {
      final res = await context.read<BookingBloc>().repository.getGoogleCalendarStatus(branchId);
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        setState(() {
          _isGoogleCalendarConnected = data['isConnected'] == true;
          _connectedEmail = data['email'];
        });
        if (_isGoogleCalendarConnected) {
          _fetchGoogleEvents();
        }
      } else {
        setState(() {
          _isGoogleCalendarConnected = false;
        });
      }
    } catch (e) {
      setState(() {
        _isGoogleCalendarConnected = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCalendarStatus = false;
        });
      }
    }
  }

  Future<void> _connectGoogleCalendar() async {
    final branchId = _getBranchId();
    if (branchId.isEmpty) return;

    try {
      final res = await context.read<BookingBloc>().repository.connectGoogleCalendar(branchId);
      if (res['success'] == true && res['data'] != null && res['data']['url'] != null) {
        final urlStr = res['data']['url'] as String;
        final uri = Uri.parse(urlStr);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch URL'), backgroundColor: Colors.red));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed to connect Google Calendar'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _disconnectGoogleCalendar() async {
    final branchId = _getBranchId();
    if (branchId.isEmpty) return;

    try {
      final res = await context.read<BookingBloc>().repository.disconnectGoogleCalendar(branchId);
      if (res['success'] == true) {
        setState(() {
          _isGoogleCalendarConnected = false;
          _connectedEmail = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Calendar disconnected'), backgroundColor: Colors.green));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed to disconnect'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _createGoogleCalendarEvent({
    required String date,
    required String time,
    required String durationStr,
    required String platform,
    required String customerName,
  }) async {
    final branchId = _getBranchId();
    if (branchId.isEmpty) return;

    try {
      final dtStr = '$date $time'.trim();
      DateTime startDt;
      try {
        startDt = DateFormat('yyyy-MM-dd HH:mm').parse(dtStr);
      } catch (e) {
        try {
          startDt = DateFormat('yyyy-MM-dd hh:mm a').parse(dtStr);
        } catch(e2) {
          startDt = DateTime.parse(date);
        }
      }

      int mins = 60;
      final match = RegExp(r'\d+').firstMatch(durationStr);
      if (match != null) {
        mins = int.parse(match.group(0)!);
      }

      final endDt = startDt.add(Duration(minutes: mins));

      final payload = {
        "branchId": branchId,
        "summary": "Appointment with $customerName",
        "description": "Booking created via Roberto Dashboard",
        "location": platform,
        "startTime": startDt.toUtc().toIso8601String(),
        "endTime": endDt.toUtc().toIso8601String(),
      };

      await context.read<BookingBloc>().repository.createGoogleCalendarEvent(payload);
    } catch(e) {
      debugPrint('Failed to create calendar event: $e');
    }
  }

  DateTime? _parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    
    // First try standard ISO parsing (e.g. 2026-06-24)
    final parsed = DateTime.tryParse(dateStr);
    if (parsed != null) return parsed;
    
    // Then try 'dd MMMM yyyy' (e.g. 22 June 2026)
    try {
      return DateFormat('dd MMMM yyyy').parse(dateStr);
    } catch (_) {}
    
    // Then try 'MMMM dd, yyyy' (e.g. June 22, 2026)
    try {
      return DateFormat('MMMM dd, yyyy').parse(dateStr);
    } catch (_) {}
    
    return null;
  }

  String _formatDeliveryDate(OrderMod order) {
    if (order.deliveryDate != null && order.deliveryDate!.isNotEmpty) {
      final parsed = _parseDateString(order.deliveryDate);
      if (parsed != null) {
        return DateFormat('dd MMM yyyy').format(parsed);
      }
      return order.deliveryDate!;
    }
    final appt = "${order.appointmentDate ?? ''} ${order.appointmentTime ?? ''}".trim();
    return appt.isNotEmpty ? appt : "N/A";
  }

  @override
  void didUpdateWidget(covariant OrderBookingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId) {
      context.read<BookingBloc>().add(GetBookings(branchId: widget.branchId ?? ''));
      _checkGoogleCalendarStatus();
    }
  }
  
  bool _isGoogleCalendarConnected = false;
  String? _connectedEmail;
  bool _isLoadingCalendarStatus = false;
  List<dynamic> _googleEvents = [];

  Future<void> _fetchGoogleEvents() async {
    final branchId = _getBranchId();
    if (branchId.isEmpty || !_isGoogleCalendarConnected) return;

    try {
      final res = await context.read<BookingBloc>().repository.getGoogleCalendarEvents(branchId);
      if (res['success'] == true && res['data'] != null && res['data'] is List) {
        if (mounted) {
          setState(() {
            _googleEvents = res['data'];
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch google calendar events: $e');
    }
  }

  int selectedIndex = 0;

  String _searchQuery = '';
  String _selectedStatus = 'All status';
  String _selectedTime = 'All time';

  // Calendar State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _checkGoogleCalendarStatus();
  }

  List<OrderMod> _orders = [];

  int _currentPage = 1;
  static const int _itemsPerPage = 20;

  List<OrderMod> get _filteredOrders {
    final filtered = _orders.where((order) {
      final matchesSearch = _searchQuery.isEmpty ||
          order.orderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.customerName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatus == 'All status' ||
          (_selectedStatus == 'Pending' &&
              order.status == OrderStatus.pending) ||
          (_selectedStatus == 'Confirmed' &&
              order.status == OrderStatus.confirmed) ||
          (_selectedStatus == 'Delivered' &&
              order.status == OrderStatus.delivered);

      return matchesSearch && matchesStatus;
    }).toList();

    return filtered;
  }

  List<OrderMod> get _paginatedOrders {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (startIndex >= _filteredOrders.length) return [];
    return _filteredOrders.sublist(
      startIndex,
      endIndex > _filteredOrders.length ? _filteredOrders.length : endIndex,
    );
  }

  //BUILD
  @override
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

        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            String? bType;
            if (profileState is ProfileLoaded) {
              bType = profileState.user.businessType;
            } else if (profileState is ProfileUpdateSuccess) {
              bType = profileState.user.businessType;
            } else if (profileState is ProfileUpdating) {
              bType = profileState.currentUser.businessType;
            }

            String titleLabel = 'Order Booking';
            String columnAddressLabel = 'Address';
            String columnPriceLabel = 'Shipping Charge';
            String columnTimeLabel = 'Delivery Time';
            String shortPriceLabel = 'Shipping';
            String shortTimeLabel = 'Delivery';
            
            if (bType != null) {
              final normalized = bType.toUpperCase().replaceAll(' ', '_');
              if (normalized == 'APPOINTMENT_BOOKING') {
                titleLabel = 'Appointment Booking';
                columnAddressLabel = 'Platform';
                columnPriceLabel = 'Price';
                columnTimeLabel = 'Appointment Date';
                shortPriceLabel = 'Price';
                shortTimeLabel = 'Date';
              } else if (normalized == 'PERCEL_BOOKING' || normalized == 'PARCEL_BOOKING' || normalized == 'PARCEL_DELIVERY') {
                titleLabel = 'Parcel Delivery';
                columnAddressLabel = 'Pickup / Delivery';
              }
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                if (state is BookingLoading && _orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final isMobile = constraints.maxWidth < _kDesktop;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isMobile, theme, isDark, titleLabel, bType),
                      SizedBox(height: isMobile ? 16 : 24),
                      _buildStatCards(isMobile, state),
                      SizedBox(height: isMobile ? 14 : 20),
                      if (selectedIndex == 0) ...[
                        _buildFilterBar(isMobile, theme, isDark),
                        SizedBox(height: isMobile ? 12 : 16),
                        isMobile ? _buildMobileCards(theme, isDark, columnAddressLabel, shortPriceLabel, shortTimeLabel, bType) : _buildDesktopTable(theme, isDark, columnAddressLabel, columnPriceLabel, columnTimeLabel, bType),
                      ] else
                        _buildCalendarContent(isMobile, theme, isDark, titleLabel),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // HEADER
  Widget _buildHeader(bool isMobile, ThemeData theme, bool isDark, String title, String? bType) {
    final titleCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 20 : 26,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track and manage all customer orders',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );

    final isAppointmentBooking = bType != null && bType.toUpperCase().replaceAll(' ', '_') == 'APPOINTMENT_BOOKING';

    final actionRow = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Toggle
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleTab(
                  label: isMobile ? 'Table' : 'Table View', index: 0, theme: theme),
              _buildToggleTab(
                  label: isMobile ? 'Calendar' : 'Calendar View',
                  index: 1,
                  theme: theme,
                  icon: Icons.calendar_today),
            ],
          ),
        ),
        if (isAppointmentBooking && selectedIndex == 1) ...[
          if (_isLoadingCalendarStatus)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (!_isGoogleCalendarConnected)
            ElevatedButton.icon(
              onPressed: _connectGoogleCalendar,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
                foregroundColor: AppColor.primary,
                side: const BorderSide(color: AppColor.primary),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.calendar_month, size: 16),
              label: Text(
                isMobile ? 'Connect Calendar' : 'Connect Google Calendar',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            )
          else ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 14,
                vertical: isMobile ? 8 : 10,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.green.withOpacity(0.05),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _connectedEmail != null ? _connectedEmail! : 'Connected',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.green),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _disconnectGoogleCalendar,
              icon: const Icon(Icons.link_off, color: Colors.red),
              tooltip: 'Disconnect Google Calendar',
            ),
          ],
        ],
        if (isAppointmentBooking && selectedIndex == 1 && _isGoogleCalendarConnected) ...[
          ElevatedButton.icon(
            onPressed: () async {
              final branchId = _getBranchId();
              if (branchId.isEmpty) return;
              final bookingBloc = context.read<BookingBloc>();
              final result = await showDialog(
                context: context,
                builder: (context) => BlocProvider.value(
                  value: bookingBloc,
                  child: CreateGoogleEventDialog(branchId: branchId),
                ),
              );
              if (result == true) {
                _fetchGoogleEvents(); // Refresh events if created
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 10 : 12,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_task, size: 16),
            label: Text(
              isMobile ? 'New Event' : 'New Event',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        // New Booking button
        ElevatedButton.icon(
          onPressed: () => _openOrderDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 10 : 12,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.add, size: 16),
          label: Text(
            isMobile ? 'New Booking' : 'New Booking',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );

    if (isMobile) {
      // Mobile: stack title on top, actions below
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleCol,
          const SizedBox(height: 12),
          actionRow,
        ],
      );
    }

    // Desktop: side-by-side
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        titleCol, 
        Expanded(child: Align(alignment: Alignment.centerRight, child: actionRow)),
      ],
    );
  }

  // ─── STAT CARDS ─────────────────────────────────────────────────────
  Widget _buildStatCards(bool isMobile, BookingState state) {
    int total = 0;
    int pending = 0;
    int confirmed = 0;
    int delivered = 0;

    if (state is BookingLoaded) {
      total = state.totalBookings;
      pending = state.pending;
      confirmed = state.confirmed;
      delivered = state.delivered;
    }

    final cards = [
      CustomStatCard(
          label: 'Total Orders', value: '$total', iconPath: 'assets/order1.svg'),
      CustomStatCard(
          label: 'Pending', value: '$pending', iconPath: 'assets/pending.svg'),
      CustomStatCard(
          label: 'Confirmed', value: '$confirmed', iconPath: 'assets/confirm.svg'),
      CustomStatCard(
          label: 'Delivered', value: '$delivered', iconPath: 'assets/deliver.svg'),
    ];

    if (!isMobile) {
      // Desktop: 4 columns
      return Row(
        children: cards.asMap().entries.map((e) {
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: e.key < cards.length - 1 ? 16 : 0),
              child: e.value,
            ),
          );
        }).toList(),
      );
    }

    // Mobile: 2×2 grid
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child:
                    Padding(padding: const EdgeInsets.only(right: 8), child: cards[0])),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child:
                    Padding(padding: const EdgeInsets.only(right: 8), child: cards[2])),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  //FILTER BAR
  Widget _buildFilterBar(bool isMobile, ThemeData theme, bool isDark) {
    final searchField = Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _currentPage = 1;
              }),
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle:
                    TextStyle(fontSize: 14, color: theme.hintColor),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );

    final statusDrop = _buildFilterDropdown(
      value: _selectedStatus,
      theme: theme,
      isDark: isDark,
      items: ['All status', 'Pending', 'Confirmed', 'Delivered'],
      onChanged: (v) => setState(() {
        _selectedStatus = v ?? 'All status';
        _currentPage = 1;
      }),
    );

    final timeDrop = _buildFilterDropdown(
      value: _selectedTime,
      theme: theme,
      isDark: isDark,
      items: ['All time', 'Today', 'This week', 'This month'],
      onChanged: (v) => setState(() {
        _selectedTime = v ?? 'All time';
        _currentPage = 1;
      }),
    );

    Widget content;
    if (isMobile) {
      // Mobile: search full width, dropdowns in a row below
      content = Column(
        children: [
          SizedBox(width: double.infinity, child: searchField),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: statusDrop),
              const SizedBox(width: 10),
              Expanded(child: timeDrop),
            ],
          ),
        ],
      );
    } else {
      // Desktop: everything in one row
      content = Row(
        children: [
          Expanded(child: searchField),
          const SizedBox(width: 12),
          statusDrop,
          const SizedBox(width: 12),
          timeDrop,
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface.withOpacity(0.5) : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: content,
    );
  }

  //DESKTOP TABLE
  Widget _buildDesktopTable(ThemeData theme, bool isDark, String addressLabel, String priceLabel, String timeLabel, String? bType) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Header row
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.5) : AppColor.secondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Expanded(flex: 2, child: CustomHeadder(label: 'Order ID', textAlign: TextAlign.center)),
                  const Expanded(flex: 3, child: CustomHeadder(label: 'Customer', textAlign: TextAlign.start)),
                  Expanded(flex: 3, child: CustomHeadder(label: addressLabel, textAlign: TextAlign.center)),
                  const Expanded(flex: 2, child: CustomHeadder(label: 'Status', textAlign: TextAlign.center)),
                  Expanded(
                      flex: 2,
                      child: CustomHeadder(label: priceLabel, textAlign: TextAlign.center)),
                  Expanded(
                      flex: 2, child: CustomHeadder(label: timeLabel, textAlign: TextAlign.center)),
                  const Expanded(flex: 3, child: CustomHeadder(label: 'Actions', textAlign: TextAlign.center)),
                ],
              ),
            ),
            // Rows
            if (_filteredOrders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text('No orders found',
                      style:
                          TextStyle(color: theme.hintColor, fontSize: 14)),
                ),
              )
            else
              ..._paginatedOrders.asMap().entries.map((entry) {
                final int globalIndex = (_currentPage - 1) * _itemsPerPage + entry.key + 1;
                return _buildDesktopRow(entry.value, globalIndex, theme, isDark, bType);
              }),
            if (_filteredOrders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomPagination(
                  totalItems: _filteredOrders.length,
                  itemsPerPage: _itemsPerPage,
                  currentPage: _currentPage,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopRow(OrderMod order, int index, ThemeData theme, bool isDark, String? bType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
            bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1), width: 1)),
      ),
      child: Row(
        children: [
          // Order ID
          Expanded(
            flex: 2,
            child: Center(
              child: Text('#$index',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: 13)),
            ),
          ),
          // Customer
          Expanded(
            flex: 3,
            child: Center(child: _buildCustomerCell(order, theme)),
          ),
          // Address
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon((bType != null && bType.toUpperCase().replaceAll(' ', '_') == 'APPOINTMENT_BOOKING') ? Icons.computer : Icons.location_on_outlined,
                    size: 14, color: theme.hintColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                      (bType != null && bType.toUpperCase().replaceAll(' ', '_') == 'APPOINTMENT_BOOKING')
                          ? (order.platform ?? order.source ?? "N/A")
                          : (bType != null && (bType.toUpperCase().replaceAll(' ', '_') == 'PERCEL_BOOKING' || bType.toUpperCase().replaceAll(' ', '_') == 'PARCEL_BOOKING'))
                              ? (order.pickupAddress ?? order.deliveryAddress ?? "N/A")
                              : (order.deliveryAddress ?? order.platform ?? order.source ?? "N/A"),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color, fontSize: 13)),
                ),
              ],
            ),
          ),
          // Status
          Expanded(flex: 2, child: Center(child: _buildStatusBadge(order.status))),
          // Shipping
          Expanded(
            flex: 2,
            child: Center(
              child: Text('\$${order.price}',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                      fontSize: 13)),
            ),
          ),
          // Delivery Time
          Expanded(
            flex: 2,
            child: Center(
              child: Text(_formatDeliveryDate(order),
                  style: TextStyle(
                      color: theme.hintColor, fontSize: 13)),
            ),
          ),
          // Actions
          Expanded(
            flex: 3,
            child: Center(child: _buildActionButtons(context, order)),
          ),
        ],
      ),
    );
  }

  // ─── MOBILE CARDS ────────────────────────────────────────────────────
  Widget _buildMobileCards(ThemeData theme, bool isDark, String addressLabel, String priceLabel, String timeLabel, String? bType) {
    if (_filteredOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text('No orders found',
              style: TextStyle(color: theme.hintColor, fontSize: 14)),
        ),
      );
    }

    return Column(
      children: [
        ..._paginatedOrders.asMap().entries.map((entry) {
          final int globalIndex = (_currentPage - 1) * _itemsPerPage + entry.key + 1;
          return _buildMobileCard(entry.value, globalIndex, theme, isDark, addressLabel, priceLabel, timeLabel, bType);
        }),
        if (_filteredOrders.isNotEmpty)
          CustomPagination(
            totalItems: _filteredOrders.length,
            itemsPerPage: _itemsPerPage,
            currentPage: _currentPage,
            onPageChanged: (page) => setState(() => _currentPage = page),
          ),
      ],
    );
  }

  Widget _buildMobileCard(OrderMod order, int index, ThemeData theme, bool isDark, String addressLabel, String priceLabel, String timeLabel, String? bType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: Order ID + Status badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#$index',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14),
              ),
              _buildStatusBadge(order.status),
            ],
          ),

          const SizedBox(height: 12),

          // ── Customer info ──
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: order.avatarColor.withOpacity(0.15),
                child: Text(
                  order.avatarInitials,
                  style: TextStyle(
                    color: order.avatarColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.customerName,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          fontSize: 13)),
                  Text(order.phone,
                      style: TextStyle(
                          fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),

          // ── Details grid ──
           Row(
            children: [
              Expanded(
                child: _buildCardDetail(
                  icon: (bType != null && bType.toUpperCase().replaceAll(' ', '_') == 'APPOINTMENT_BOOKING') ? Icons.computer : Icons.location_on_outlined,
                  label: addressLabel,
                  value: (bType != null && bType.toUpperCase().replaceAll(' ', '_') == 'APPOINTMENT_BOOKING')
                          ? (order.platform ?? order.source ?? "N/A")
                          : (bType != null && (bType.toUpperCase().replaceAll(' ', '_') == 'PERCEL_BOOKING' || bType.toUpperCase().replaceAll(' ', '_') == 'PARCEL_BOOKING'))
                              ? (order.pickupAddress ?? order.deliveryAddress ?? "N/A")
                              : (order.deliveryAddress ?? order.platform ?? order.source ?? "N/A"),
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCardDetail(
                  icon: Icons.attach_money,
                  label: priceLabel,
                  value: '\$${order.price}',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _buildCardDetail(
                  icon: Icons.access_time,
                  label: timeLabel,
                  value: _formatDeliveryDate(order),
                  theme: theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),

          // ── Action buttons ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CustomViewdetails(
                        order: order,
                        displayId: '#$index',
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 15),
                  label: const Text('View Details', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              _buildIconBtn(
                  icon: Icons.edit_outlined,
                  color: Colors.blue.shade400,
                  onTap: () => _openOrderDialog(order: order)),
              const SizedBox(width: 6),
              _buildIconBtn(
                  icon: Icons.delete_outline,
                  color: Colors.red.shade400,
                  onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetail(
      {required IconData icon,
      required String label,
      required String value,
      required ThemeData theme}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: theme.textTheme.bodySmall?.color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color)),
              Text(value,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────────────────

  Widget _buildCustomerCell(OrderMod order, ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: order.avatarColor.withOpacity(0.15),
          child: Text(order.avatarInitials,
              style: TextStyle(
                  color: order.avatarColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.customerName,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                      fontSize: 13)),
              Text(order.phone,
                  style: TextStyle(
                      fontSize: 11, color: theme.textTheme.bodySmall?.color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderMod order) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final int idx = _filteredOrders.indexOf(order);
            final String displayId = idx != -1 ? '#${idx + 1}' : order.orderId;
            showDialog(
              context: context,
              builder: (context) => CustomViewdetails(
                order: order,
                displayId: displayId,
                onUpdatePressed: () => _showStatusUpdateDialog(order, displayId),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            ),
            child: Text('View Details',
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 12)),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => _openOrderDialog(order: order),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.edit_outlined,
                size: 16, color: theme.iconTheme.color?.withOpacity(0.6)),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.delete_outline,
                size: 16, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTab(
      {required String label, required int index, required ThemeData theme, IconData? icon}) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ThemeData theme,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: theme.cardColor,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface)),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: theme.textTheme.bodySmall?.color),
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    late Color bg, fg;
    late String label;
    late IconData icon;

    switch (status) {
      case OrderStatus.pending:
        bg = isDark ? Colors.amber.withOpacity(0.1) : const Color(0xffFEF3C7);
        fg = isDark ? Colors.amber.shade400 : const Color(0xffD97706);
        label = 'Pending';
        icon = Icons.access_time;
        break;
      case OrderStatus.confirmed:
        bg = isDark ? Colors.blue.withOpacity(0.1) : const Color(0xffDBEAFE);
        fg = isDark ? Colors.blue.shade400 : const Color(0xff2563EB);
        label = 'Confirmed';
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.completed:
        bg = isDark ? Colors.green.withOpacity(0.1) : const Color(0xffD1FAE5);
        fg = isDark ? Colors.green.shade400 : const Color(0xff059669);
        label = 'Completed';
        icon = Icons.check_circle;
        break;
      case OrderStatus.delivered:
        bg = isDark ? Colors.green.withOpacity(0.1) : const Color(0xffD1FAE5);
        fg = isDark ? Colors.green.shade400 : const Color(0xff059669);
        label = 'Delivered';
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.cancelled:
        bg = isDark ? Colors.red.withOpacity(0.1) : const Color(0xffFEE2E2);
        fg = isDark ? Colors.red.shade400 : const Color(0xffDC2626);
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── CALENDAR VIEW ──────────────────────────────────────────────────
  Widget _buildCalendarContent(bool isMobile, ThemeData theme, bool isDark, String title) {
    if (isMobile) {
      return Column(
        children: [
          _buildCalendarPane(theme, isDark, title),
          const SizedBox(height: 16),
          _buildCalendarSidebar(theme, isDark),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: _buildCalendarPane(theme, isDark, title)),
        const SizedBox(width: 24),
        Expanded(flex: 3, child: _buildCalendarSidebar(theme, isDark)),
      ],
    );
  }

  Widget _buildCalendarPane(ThemeData theme, bool isDark, String title) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isHeaderStacked = headerConstraints.maxWidth < 450;
              return isHeaderStacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendarTitle(theme, title),
                        const SizedBox(height: 16),
                        _buildCalendarNav(theme, isDark),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCalendarTitle(theme, title),
                        _buildCalendarNav(theme, isDark),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),
          // Calendar Grid
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerVisible: false,
            daysOfWeekHeight: 40,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: theme.textTheme.bodySmall?.color ?? const Color(0xff6B7280), fontSize: 13),
              weekendStyle:
                  TextStyle(color: theme.textTheme.bodySmall?.color ?? const Color(0xff6B7280), fontSize: 13),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(8),
              defaultTextStyle: TextStyle(
                  fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
              weekendTextStyle: TextStyle(
                  fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
              todayDecoration: const BoxDecoration(
                  color: Colors.transparent, shape: BoxShape.rectangle),
              todayTextStyle: TextStyle(
                  fontWeight: FontWeight.w500, color: theme.colorScheme.primary),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(12),
              ),
              selectedTextStyle: TextStyle(
                  fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildCalendarCell(day, theme, isDark);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildCalendarCell(day, theme, isDark, isSelected: true);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildCalendarCell(day, theme, isDark, isToday: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day, ThemeData theme, bool isDark,
      {bool isSelected = false, bool isToday = false}) {
    // Count orders dynamically for this day
    final dayOrders = _orders.where((o) {
      final orderDate = _parseDateString(o.deliveryDate) ?? _parseDateString(o.appointmentDate);
      return orderDate != null && orderDate.year == day.year && orderDate.month == day.month && orderDate.day == day.day;
    }).toList();
    
    final googleDayEvents = _googleEvents.where((e) {
      final start = e['start']?['dateTime'];
      if (start != null) {
        final eventDate = DateTime.tryParse(start)?.toLocal();
        return eventDate != null && eventDate.year == day.year && eventDate.month == day.month && eventDate.day == day.day;
      }
      return false;
    }).toList();
    
    int eventCount = dayOrders.length + googleDayEvents.length;
    final hasEvent = eventCount > 0;
    final isSelectedActive = isSelected;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelectedActive
            ? AppColor.primary
            : hasEvent
                ? AppColor.primary.withOpacity(0.15)
                : isSelected
                    ? theme.dividerColor.withOpacity(0.2)
                    : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: isSelected || hasEvent
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : hasEvent
                        ? AppColor.primary
                        : theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          if (hasEvent)
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$eventCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, ThemeData theme, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 16, color: theme.textTheme.bodyMedium?.color ?? const Color(0xff6B7280)),
      ),
    );
  }

  Widget _buildCalendarTitle(ThemeData theme, String title) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined,
            size: 20, color: theme.colorScheme.onSurface),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildCalendarNav(ThemeData theme, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavIcon(Icons.chevron_left, theme, isDark, () {
          setState(() {
            _focusedDay = DateTime(
                _focusedDay.year, _focusedDay.month - 1, _focusedDay.day);
          });
        }),
        const SizedBox(width: 16),
        Text(_getMonthYear(_focusedDay),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(width: 16),
        _buildNavIcon(Icons.chevron_right, theme, isDark, () {
          setState(() {
            _focusedDay = DateTime(
                _focusedDay.year, _focusedDay.month + 1, _focusedDay.day);
          });
        }),
      ],
    );
  }

  String _getMonthYear(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCalendarSidebar(ThemeData theme, bool isDark) {
    final selectedDay = _selectedDay ?? DateTime.now();
    final dayStr = '${_getMonthYear(selectedDay).split(' ')[0]} ${selectedDay.day}';

    final filteredOrders = _orders.where((o) {
      final orderDate = _parseDateString(o.deliveryDate) ?? _parseDateString(o.appointmentDate);
      return orderDate != null && orderDate.year == selectedDay.year && orderDate.month == selectedDay.month && orderDate.day == selectedDay.day;
    }).toList();

    final googleFilteredEvents = _googleEvents.where((e) {
      final start = e['start']?['dateTime'];
      if (start != null) {
        final eventDate = DateTime.tryParse(start)?.toLocal();
        return eventDate != null && eventDate.year == selectedDay.year && eventDate.month == selectedDay.month && eventDate.day == selectedDay.day;
      }
      return false;
    }).toList();

    final totalEvents = filteredOrders.length + googleFilteredEvents.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Orders & Events for $dayStr',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('$totalEvents scheduled items',
            style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color ?? const Color(0xff6B7280))),
        const SizedBox(height: 16),
        
        if (totalEvents == 0)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 40, color: theme.hintColor.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No orders or events scheduled for this date',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.hintColor, fontSize: 13)),
                ],
              ),
            ),
          )
        else ...[
          ...filteredOrders.map((order) => _buildSidebarOrderCard(
                context: context,
                order: order,
                theme: theme,
                isDark: isDark,
              )),
          ...googleFilteredEvents.map((event) => _buildSidebarGoogleEventCard(
                context: context,
                event: event,
                theme: theme,
                isDark: isDark,
              )),
        ],
      ],
    );
  }

  Widget _buildSidebarGoogleEventCard({
    required BuildContext context,
    required dynamic event,
    required ThemeData theme,
    required bool isDark,
  }) {
    final summary = event['summary'] ?? 'No Title';
    final location = event['location'] ?? 'No Location';
    final startDtStr = event['start']?['dateTime'];
    final endDtStr = event['end']?['dateTime'];
    
    String timeStr = 'All Day';
    if (startDtStr != null && endDtStr != null) {
      final start = DateTime.tryParse(startDtStr)?.toLocal();
      final end = DateTime.tryParse(endDtStr)?.toLocal();
      if (start != null && end != null) {
        final startF = DateFormat('hh:mm a').format(start);
        final endF = DateFormat('hh:mm a').format(end);
        timeStr = '$startF - $endF';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeStr, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text('Google Calendar', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(summary, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, fontSize: 15)),
          const SizedBox(height: 8),
          _buildSidebarItemRow(Icons.location_on_outlined, location, theme),
        ],
      ),
    );
  }

  Widget _buildSidebarOrderCard({
    required BuildContext context,
    required OrderMod order,
    required ThemeData theme,
    required bool isDark,
  }) {
    final status = order.status;
    final int idx = _orders.indexOf(order);
    final String displayId = idx != -1 ? '#${idx + 1}' : order.orderId;
    final time = _formatDeliveryDate(order);
    final name = order.customerName;
    final items = '${order.note ?? "Booking"} x1';
    final actionText = status == OrderStatus.pending ? 'Mark as Confirmed' : 'Mark as Delivered';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayId,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: 14)),
                  Text(time,
                      style: TextStyle(
                          fontSize: 12, color: theme.textTheme.bodySmall?.color ?? const Color(0xff6B7280))),
                ],
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 16),
          Text(name,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  fontSize: 13)),
          const SizedBox(height: 8),
          _buildSidebarItemRow(Icons.location_on_outlined,
              '123 Main St, City to\n123 Main St, City', theme),
          const SizedBox(height: 6),
          _buildSidebarItemRow(Icons.phone_outlined, '+1 234 567 8901', theme),
          const SizedBox(height: 6),
          _buildSidebarItemRow(Icons.inventory_2_outlined, items, theme),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final int idx = _orders.indexOf(order);
                final String displayId = idx != -1 ? '#${idx + 1}' : order.orderId;

                showDialog(
                  context: context,
                  builder: (context) => CustomViewdetails(
                    order: order,
                    displayId: displayId,
                    onUpdatePressed: () => _showStatusUpdateDialog(order, displayId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(actionText,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: order.conversationId != null ? () {
                widget.onNavigate?.call('Inbox', targetPhone: order.phone, conversationId: order.conversationId);
              } : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: order.conversationId != null ? AppColor.primary : Colors.grey,
                side: BorderSide(color: order.conversationId != null ? AppColor.primary : Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(order.conversationId != null ? Icons.chat_outlined : Icons.phone_callback_outlined, size: 16),
              label: Text(order.conversationId != null ? 'See Latest Chat' : 'Order from calls',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          )
        ],
      ),
    );
  }



  void _updateOrderStatus(String orderId, OrderStatus newStatus) {
    // Determine string status
    String statusStr = 'PENDING';
    if (newStatus == OrderStatus.confirmed) {
      statusStr = 'CONFIRMED';
    } else if (newStatus == OrderStatus.completed) {
      statusStr = 'COMPLETED';
    } else if (newStatus == OrderStatus.delivered) {
      statusStr = 'DELIVERED';
    } else if (newStatus == OrderStatus.cancelled) {
      statusStr = 'CANCELLED';
    }
    
    context.read<BookingBloc>().add(UpdateBooking(id: orderId, payload: {'status': statusStr}, branchId: _getBranchId()));
  }

  String? _getBusinessType() {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      return profileState.user.businessType;
    } else if (profileState is ProfileUpdateSuccess) {
      return profileState.user.businessType;
    }
    return null;
  }

  void _openOrderDialog({OrderMod? order}) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => CreateOrderDialog(
        order: order,
        businessType: _getBusinessType(),
      ),
    ).then((result) {
      if (!mounted) return;
      if (result != null && result is Map<String, dynamic>) {
        if (order != null) {
          context.read<BookingBloc>().add(UpdateBooking(
                id: order.orderId,
                payload: result,
                branchId: _getBranchId(),
              ));
        } else {
          // Check if appointment booking to create Google Calendar event
          final addDetails = result['additionalDetails'] as List<Map<String, String>>?;
          bool isAppt = false;
          String? apptDate, apptTime, platform, duration;
          if (addDetails != null) {
            for (var d in addDetails) {
              if (d['key'] == 'bookingType' && d['value'] == 'Appointment Booking') isAppt = true;
              if (d['key'] == 'appointmentDate') apptDate = d['value'];
              if (d['key'] == 'appointmentTime') apptTime = d['value'];
              if (d['key'] == 'platform') platform = d['value'];
              if (d['key'] == 'duration') duration = d['value'];
            }
          }

          if (isAppt && apptDate != null && apptDate.isNotEmpty) {
            _createGoogleCalendarEvent(
              date: apptDate,
              time: apptTime ?? '10:00', // fallback
              durationStr: duration ?? '60 Minutes',
              platform: platform ?? 'Zoom',
              customerName: result['customerName']?.toString() ?? 'Customer',
            );
          }

          context.read<BookingBloc>().add(CreateBooking(
                payload: result,
                branchId: _getBranchId(),
              ));
        }
      }
    });
  }

  void _showStatusUpdateDialog(OrderMod order, [String? displayId]) {
    const CustomOrders().showUpdateStatusDialog(
      context: context,
      order: order,
      displayId: displayId,
      onUpdate: (status) {
        _updateOrderStatus(order.orderId, status);
      },
    );
  }

  Widget _buildSidebarItemRow(IconData icon, String text, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: theme.textTheme.bodySmall?.color ?? const Color(0xff9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12, color: theme.textTheme.bodyMedium?.color ?? const Color(0xff6B7280)))),
      ],
    );
  }
}