class ApiConstants {
  static const String baseUrl = 'https://accustomed-maryalice-bubbleless.ngrok-free.dev/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String verifyOtp = '$baseUrl/auth/verify-forgot-password-otp';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String refreshToken = '$baseUrl/auth/refresh-token';

  // Overview endpoints
  static const String systemOwnerOverview = '$baseUrl/system-owner/dashboard/overview';
  static const String businessOwnerOverview = '$baseUrl/business-owner/dashboard/overview';

  // Subscription endpoints
  static const String systemOwnerSubscriptions = '$baseUrl/system-owner/subscription-plans/all';

  // Profile endpoints
  static const String getProfile = '$baseUrl/user/profile/me';
  static const String updateProfile = '$baseUrl/user/update-profile';

  // Notification endpoints
  static const String notifications = '$baseUrl/notifications';
  static const String notificationsReadAll = '$baseUrl/notifications/read-all';

  // Business (Tenant) endpoints
  static const String systemOwnerBusinesses = '$baseUrl/system-owner/businesses/all';
  static const String systemOwnerBusinessSingle = '$baseUrl/system-owner/businesses'; // + /:id
  static const String systemOwnerBusinessCreate = '$baseUrl/system-owner/businesses/create';

  // Agent Training endpoints
  static const String systemOwnerAgentTrainings = '$baseUrl/system-owner/agent-trainings/all';
  static const String systemOwnerAgentTrainingsCreate = '$baseUrl/system-owner/agent-trainings/create';
  static const String systemOwnerAgentTrainingsSingle = '$baseUrl/system-owner/agent-trainings'; // + /:id
}
