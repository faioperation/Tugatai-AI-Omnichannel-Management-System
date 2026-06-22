import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/sidebar_item.dart';
import 'package:roberto/features/Tenant Management /screen/tenant_screen.dart';
import 'package:roberto/features/Subscription/screen/subscription_screen.dart';
import 'package:roberto/features/Settings/screen/setting_screen.dart';
import 'package:roberto/features/Orderbooking/screen/order_booking_screen.dart';
import 'package:roberto/features/Inbox/screen/inbox_screen.dart';
import 'package:roberto/features/AiAgent/screen/aiagent_screen.dart';
import 'package:roberto/features/Pricing/screen/pricing_screen.dart';
import 'package:roberto/features/CRM/screen/cmr_screen.dart';
import 'package:roberto/features/notification/screen/notification_screen.dart';
import 'package:roberto/features/management/screen/management_screen.dart';
import 'package:roberto/features/businesssetting/screen/businessowner_settings.dart';
import 'package:roberto/features/businesssubscription/screen/business_subscription.dart';
import 'package:roberto/features/Overview/screen/overview_screen.dart';
import 'package:roberto/features/DemoBooking/screen/demo_booking_screen.dart';
import 'package:roberto/features/WhatsAppCampaigns/screen/whatsapp_campaigns_screen.dart';
import 'package:roberto/app/app_routes.dart';
import 'package:roberto/common/user_role.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Settings/bloc/profile_bloc.dart';
import 'package:roberto/features/Settings/bloc/profile_event.dart';
import 'package:roberto/features/Settings/bloc/profile_state.dart';
import 'package:roberto/features/notification/bloc/notification_bloc.dart';
import 'package:roberto/features/notification/bloc/notification_event.dart';
import 'package:roberto/features/notification/bloc/notification_state.dart';

class DashboardShell extends StatefulWidget {
  final UserRole role;
  final Map<String, String>? assignedBranch;
  final String? initialItem;

  const DashboardShell({
    super.key,
    this.role = UserRole.businessOwner,
    this.assignedBranch,
    this.initialItem,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeItem = 'Overview';
  
  final List<Map<String, String>> _branches = [
    {"name": "Queens Center", "address": "719/B, Queens, NY"},
    {"name": "Brooklyn Hub", "address": "123, Brooklyn, NY"},
    {"name": "Manhattan Store", "address": "456, Manhattan, NY"},
  ];
  late Map<String, String> _selectedBranch;

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.assignedBranch ?? _branches[0];
    if (widget.initialItem != null) {
      _activeItem = widget.initialItem!;
    }
    
    // Fetch initial data
    context.read<ProfileBloc>().add(FetchProfileRequested());
    context.read<NotificationBloc>().add(FetchNotificationsRequested());
  }

  void _navigateTo(String item) {
    String? route;
    switch (item) {
      case 'Overview': route = Routes.overview; break;
      case 'Inbox': route = Routes.inbox; break;
      case 'Order Booking': route = Routes.orderBooking; break;
      case 'AI Agent': route = Routes.aiAgent; break;
      case 'Pricing': route = Routes.pricing; break;
      case 'Campaigns': route = Routes.campaigns; break;
      case 'CRM & Leads': route = Routes.crmLeads; break;
      case 'Subscriptions': route = Routes.subscriptions; break;
      case 'Management': route = Routes.management; break;
      case 'Settings': route = Routes.settings; break;
      // case 'Demo Bookings': route = Routes.demoBookings; break;
      case 'Notifications': route = Routes.notifications; break;
      case 'Edit Profile': route = Routes.settings; break;
      case 'Tenant Management': route = Routes.management; break; // Map to management or dedicated route
    }

    String rolePath = '';
    if (widget.role == UserRole.systemOwner) {
      rolePath = '/system-owner';
    } else if (widget.role == UserRole.businessOwner) {
      rolePath = '/business-owner';
    } else if (widget.role == UserRole.branchManager) {
      rolePath = '/branch-manager';
    }

    String fullRoute = '$rolePath$route';

    if (route != null && fullRoute != ModalRoute.of(context)?.settings.name) {
      Navigator.pushReplacementNamed(
        context,
        fullRoute,
        arguments: {
          'role': widget.role,
          'assignedBranch': _selectedBranch,
        },
      );
    } else {
      setState(() {
        _activeItem = item;
      });
    }
  }

  void _selectItem(String item) {
    _navigateTo(item);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(context)),
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (isDesktop) RepaintBoundary(child: _buildSidebar(context)),
            Expanded(
              child: Column(
                children: [
                  RepaintBoundary(child: _buildTopBar(context)),
                  Expanded(
                    child: RepaintBoundary(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildContent(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {

    switch (_activeItem) {
      case 'Inbox':
        return widget.role == UserRole.systemOwner
            ? const DemoBookingScreen() // System Owner's inbox is Demo Bookings
            : InboxScreen(isSystemOwner: widget.role == UserRole.systemOwner);
      case 'Tenant Management':
      case 'Management':
        return widget.role == UserRole.systemOwner
            ? const TenantScreen()
            : const ManagementScreen();

      case 'Subscriptions':
        return widget.role == UserRole.systemOwner
            ? const SubscriptionScreen()
            : const BusinessSubscription();

      case 'Settings':
        return widget.role == UserRole.systemOwner
            ? const SettingScreen()
            : const BusinessownerSettings();

      case 'Order Booking':
        return OrderBookingScreen(onNavigate: _selectItem);

      case 'AI Agent':
        return const AiagentScreen();

      case 'Pricing':
        return const PricingScreen();

      case 'CRM & Leads':
        return CmrScreen(onNavigate: _selectItem);

      case 'Management':
        return const ManagementScreen();

      case 'Notifications':
        return const NotificationScreen();

      // case 'Demo Bookings':
      //   return const DemoBookingScreen();

      case 'Edit Profile':
        return const SettingScreen();

      case 'Campaigns':
        return const WhatsAppCampaignsScreen();

      case 'Overview':

      default:
        return OverviewScreen(role: widget.role);
    }
  }


  // ─── Sidebar ─────────────────────────────────────────────────────────────
  
  static const List<Map<String, dynamic>> _systemOwnerItems = [
    {'icon': 'assets/overview.svg', 'label': 'Overview'},
    // {'icon': 'assets/inbox.svg', 'label': 'Demo Bookings'},
    {'icon': 'assets/subscription.svg', 'label': 'Tenant Management'},
    {'icon': 'assets/subscription.svg', 'label': 'Subscriptions'},
    {'icon': 'assets/setting.svg', 'label': 'Settings'},
  ];

  static const List<Map<String, dynamic>> _businessOwnerItems = [
    {'icon': 'assets/overview.svg', 'label': 'Overview'},
    {'icon': 'assets/inbox.svg', 'label': 'Inbox'},
    {'icon': 'assets/order.svg', 'label': 'Order Booking'},
    {'icon': 'assets/aiagent.svg', 'label': 'AI Agent'},
    {'icon': 'assets/pricing.svg', 'label': 'Pricing'},
    {'icon': Icons.send, 'label': 'Campaigns'},
    {'icon': 'assets/crm.svg', 'label': 'CRM & Leads'},
    {'icon': 'assets/subscription.svg', 'label': 'Subscriptions'},
    {'icon': 'assets/management.svg', 'label': 'Management'},
    {'icon': 'assets/setting.svg', 'label': 'Settings'},
  ];

  static const List<Map<String, dynamic>> _branchManagerItems = [
    {'icon': 'assets/overview.svg', 'label': 'Overview'},
    {'icon': 'assets/inbox.svg', 'label': 'Inbox'},
    {'icon': 'assets/order.svg', 'label': 'Order Booking'},
    {'icon': 'assets/pricing.svg', 'label': 'Pricing'},
    {'icon': 'assets/crm.svg', 'label': 'CRM & Leads'},
  ];

  Widget _buildSidebar(BuildContext context) {
    List<Map<String, dynamic>> items;
    if (widget.role == UserRole.systemOwner) {
      items = _systemOwnerItems;
    } else if (widget.role == UserRole.branchManager) {
      items = _branchManagerItems;
    } else {
      items = _businessOwnerItems;
    }

    return Container(
      width: 260,
      color: Theme.of(context).cardTheme.color,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SvgPicture.asset('assets/logo.svg', height: 60),
                const SizedBox(height: 10),
                const Text(
                  "TUGATAI",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (widget.role != UserRole.systemOwner) ...[
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).dividerTheme.color, height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Theme(
                data: Theme.of(context).copyWith(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: widget.role == UserRole.branchManager
                    ? _buildStaticBranchInfo(context)
                    : PopupMenuButton<Map<String, String>>(
                        offset: const Offset(0, 50),
                        position: PopupMenuPosition.under,
                        color: Theme.of(context).cardTheme.color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onSelected: (Map<String, String> branch) {
                          setState(() {
                            _selectedBranch = branch;
                          });
                        },
                        itemBuilder: (context) => _branches.map((branch) {
                          return PopupMenuItem<Map<String, String>>(
                            value: branch,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  branch['name']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: branch == _selectedBranch
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                Text(
                                  branch['address']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                                if (branch != _branches.last)
                                  const Divider(height: 16),
                              ],
                            ),
                          );
                        }).toList(),
                        child: _buildBranchSelectorTrigger(context),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const SizedBox(height: 32),
          ],
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: items.map((item) {
                final label = item['label']! as String;
                final iconData = item['icon'];
                return SidebarItem(
                  iconPath: iconData is String ? iconData : null,
                  icon: iconData is IconData ? iconData : null,
                  label: label,
                  isActive: _activeItem == label,
                  onTap: () {
                    _selectItem(label);
                    // Close drawer on mobile after selection
                    if (MediaQuery.of(context).size.width <= 900) {
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top Bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width <= 900;
    final bool isSmallMobile = width <= 600;

    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE))),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),

          if (isMobile && !isSmallMobile)
            IconButton(
              icon: const Icon(Icons.search, color: AppColor.grey),
              onPressed: () {
                // Future: show search bar overlay
              },
            ),

          const Spacer(),

          // Notifications
          _buildNotificationIcon(),

          const SizedBox(width: 16),

          // User Profile
          _buildUserProfile(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int count = state.unreadCount;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined, color: AppColor.grey),
              onPressed: () {
                _selectItem('Notifications');
              },
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: AppColor.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserProfile(BuildContext context, bool isMobile) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String name = "Loading...";
        String? avatarUrl;

        if (state is ProfileLoaded || state is ProfileUpdating || state is ProfileUpdateSuccess) {
          final user = (state is ProfileLoaded)
              ? state.user
              : (state is ProfileUpdating)
                  ? state.currentUser
                  : (state as ProfileUpdateSuccess).user;
          name = "${user.firstName} ${user.lastName ?? ''}".trim();
          if (name.isEmpty) name = "User";
          avatarUrl = user.profilePicture;
        }

        return PopupMenuButton<String>(
          color: Theme.of(context).cardTheme.color,
          padding: EdgeInsets.zero,
          offset: const Offset(0, 45),
          onSelected: (value) {
            if (value == 'logout') {
              Navigator.pushReplacementNamed(context, Routes.login);
            } else if (value == 'profile') {
              _selectItem('Edit Profile');
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            if (widget.role != UserRole.systemOwner)
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Profile', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: AppColor.primary),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: AppColor.primary, fontSize: 14)),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 17.5,
                  backgroundColor: AppColor.mini,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? const Icon(Icons.person, color: AppColor.white, size: 18)
                      : null,
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 10),
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColor.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaticBranchInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      ),
      child: _buildBranchInfoContent(context, showArrow: false),
    );
  }

  Widget _buildBranchSelectorTrigger(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      ),
      child: _buildBranchInfoContent(context, showArrow: true),
    );
  }

  Widget _buildBranchInfoContent(BuildContext context,
      {required bool showArrow}) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined,
            color: AppColor.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedBranch['name']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _selectedBranch['address']!,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        if (showArrow)
          Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
      ],
    );
  }
}
