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
  static const String branchManagerOverview = '$baseUrl/branch-manager/dashboard/overview';

  // Subscription endpoints
  static const String systemOwnerSubscriptions = '$baseUrl/system-owner/subscription-plans/all';
  static const String businessOwnerMySubscription = '$baseUrl/payment/my-subscription';

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

  // Management endpoints
  static const String businessOwnerBranchManagers = '$baseUrl/business-owner/branch-managers/all';
  static const String businessOwnerBranchManagersCreate = '$baseUrl/business-owner/branch-managers/create';
  static const String businessOwnerBranchManagersDelete = '$baseUrl/business-owner/branch-managers'; // + /:id
  // Campaign endpoints
  static const String businessOwnerCampaigns = '$baseUrl/business-owner/campaigns/all';
  static const String businessOwnerCampaignCreate = '$baseUrl/business-owner/campaigns/create';
  static const String businessOwnerCampaignUpdate = '$baseUrl/business-owner/campaigns'; // + /:id
  static const String businessOwnerCampaignDelete = '$baseUrl/business-owner/campaigns'; // + /:id

  // CRM Leads endpoints
  static const String businessOwnerCrmLeads = '$baseUrl/business-owner/crm-leads/all';
  static const String businessOwnerCrmLeadCreate = '$baseUrl/business-owner/crm-leads/create';
  static const String businessOwnerCrmLead = '$baseUrl/business-owner/crm-leads'; // + /:id (for GET single, PATCH, DELETE)

  // Branch Manager CRM Leads endpoints
  static const String branchManagerCrmLeads = '$baseUrl/branch-manager/crm-leads/all';
  static const String branchManagerCrmLeadCreate = '$baseUrl/branch-manager/crm-leads/create';
  static const String branchManagerCrmLead = '$baseUrl/branch-manager/crm-leads'; // + /:id (for GET single, PATCH, DELETE)

  // Branch Manager Pricing endpoints
  static const String branchManagerPricingAll = '$baseUrl/branch-manager/pricing/all';
  static const String branchManagerPricingCreate = '$baseUrl/branch-manager/pricing/create';
  static const String branchManagerPricingSingle = '$baseUrl/branch-manager/pricing'; // + /:id
}
