import 'package:flutter/material.dart';
import 'package:roberto/features/Auth/screen/login_screen.dart';
import 'package:roberto/features/Auth/screen/forgot_screen.dart';
import 'package:roberto/features/Auth/screen/verify_screen.dart';
import 'package:roberto/features/Auth/screen/reset_screen.dart';
import 'package:roberto/features/Auth/screen/successful_screen.dart';
import 'package:roberto/common/dashboard_layout.dart';
import 'package:roberto/common/user_role.dart';

class Routes {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String success = '/success';

  // Dashboard Routes
  static const String overview = '/overview';
  static const String inbox = '/inbox';
  static const String orderBooking = '/booking';
  static const String aiAgent = '/ai-agent';
  static const String pricing = '/pricing';
  static const String campaigns = '/campaigns';
  static const String crmLeads = '/crm-leads';
  static const String subscriptions = '/subscriptions';
  static const String management = '/management';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String demoBookings = '/demo-bookings';
  static const String notifications = '/notifications';
  static const String allUsers = '/all-users';
  static const String staffManagement = '/staff-management';
  static const String webChat = '/web-chat';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    String routeName = settings.name ?? '';
    final uri = Uri.parse(routeName);
    routeName = uri.path;
    final queryParams = uri.queryParameters;

    // Parse role and actual route from name
    UserRole? routeRole;
    String actualRoute = routeName;

    if (routeName.startsWith('/system-owner')) {
      routeRole = UserRole.systemOwner;
      actualRoute = routeName.replaceFirst('/system-owner', '');
    } else if (routeName.startsWith('/business-owner')) {
      routeRole = UserRole.businessOwner;
      actualRoute = routeName.replaceFirst('/business-owner', '');
    } else if (routeName.startsWith('/branch-manager')) {
      routeRole = UserRole.branchManager;
      actualRoute = routeName.replaceFirst('/branch-manager', '');
    }

    // Standard dashboard case
    if (isDashboardRoute(actualRoute)) {
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      final role =
          args['role'] as UserRole? ?? routeRole ?? UserRole.businessOwner;
      final branch = args['assignedBranch'] as Map<String, String>?;
      final businessId = args['businessId'] as String?;
      final conversationId =
          queryParams['conversationId'] ?? args['conversationId'] as String?;

      return PageRouteBuilder(
        settings: settings,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) => DashboardShell(
          role: role,
          assignedBranch: branch,
          initialItem: getDashboardItem(actualRoute, role: role),
          initialBusinessId: businessId,
          initialConversationId: conversationId,
        ),
      );
    }

    switch (routeName) {
      case login:
      case '/':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotScreen(),
        );
      case verifyOtp:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerifyScreen(email: email),
        );
      case resetPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ResetScreen(),
        );
      case success:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SuccessfulScreen(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static bool isDashboardRoute(String name) {
    // Check if the name matches any of the routes, with or without leading slash
    String normalizedName = name.startsWith('/') ? name : '/$name';
    return [
      overview,
      inbox,
      orderBooking,
      aiAgent,
      pricing,
      campaigns,
      crmLeads,
      subscriptions,
      management,
      settings,
      editProfile,
      demoBookings,
      notifications,
      allUsers,
      staffManagement,
      webChat,
    ].contains(normalizedName);
  }

  static String getDashboardItem(
    String route, {
    UserRole role = UserRole.businessOwner,
  }) {
    String normalizedRoute = route.startsWith('/') ? route : '/$route';
    switch (normalizedRoute) {
      case overview:
        return 'Overview';
      case inbox:
        return 'Inbox';
      case orderBooking:
        return 'Order Booking';
      case aiAgent:
        return 'AI Agent';
      case pricing:
        return 'Pricing';
      case campaigns:
        return 'Campaigns';
      case crmLeads:
        return 'CRM & Leads';
      case subscriptions:
        return 'Subscriptions';
      case management:
        return (role == UserRole.systemOwner || role == UserRole.systemStaff)
            ? 'Tenant Management'
            : 'Management';
      case settings:
        return 'Settings';
      case editProfile:
        return 'Edit Profile';
      case demoBookings:
        return 'Demo Bookings';
      case notifications:
        return 'Notifications';
      case allUsers:
        return 'All Users';
      case staffManagement:
        return 'Staff Management';
      case webChat:
        return 'Web Chat';
      default:
        return 'Overview';
    }
  }
}
