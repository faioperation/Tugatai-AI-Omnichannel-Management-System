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
  static const String createCheckoutSession = '$baseUrl/payment/create-checkout-session';

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

  // Agent Management endpoints
  static const String systemOwnerAgentManagementAll = '$baseUrl/system-owner/agent-management/all';
  static const String systemOwnerAgentManagementCreate = '$baseUrl/system-owner/agent-management/create';
  static const String systemOwnerAgentManagementSingle = '$baseUrl/system-owner/agent-management'; // + /:id
  static const String systemOwnerSetupTwilio = '$baseUrl/system-owner/telephony/setup-twilio';

  // Management endpoints
  static const String businessOwnerBranchManagers = '$baseUrl/business-owner/branch-managers/all';
  static const String businessOwnerBranchManagersCreate = '$baseUrl/business-owner/branch-managers/create';
  static const String businessOwnerBranchManagersDelete = '$baseUrl/business-owner/branch-managers'; // + /:id
  static const String businessOwnerBranchesAll = '$baseUrl/business-owner/branches/all';
  static const String businessOwnerBranchesCreate = '$baseUrl/business-owner/branches/create';
  static const String businessOwnerBranchesSingle = '$baseUrl/business-owner/branches'; // + /:id
  
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

  // Branch Manager Booking endpoints
  static const String branchManagerBookingsAll = '$baseUrl/branch-manager/bookings/all';
  static const String branchManagerBookingsCreate = '$baseUrl/branch-manager/bookings/create';
  static const String branchManagerBookingsSingle = '$baseUrl/branch-manager/bookings'; // + /:id

  // Inbox & Conversations
  static const String allConversations = '$baseUrl/conversations/all-conversations';
  
  static const String messengerConversations = '$baseUrl/v1/messenger/conversations';
  static const String messengerMessages = '$baseUrl/v1/messenger/messages'; // + /:conversationId
  static const String messengerSendText = '$baseUrl/v1/messenger/messages/send';
  static const String messengerSendMedia = '$baseUrl/v1/messenger/messages/media';
  
  static const String instagramConversations = '$baseUrl/v1/instagram/conversations';
  static const String instagramMessages = '$baseUrl/v1/instagram/messages'; // + /:conversationId
  static const String instagramSendText = '$baseUrl/v1/instagram/messages/send';
  static const String instagramSendMedia = '$baseUrl/v1/instagram/messages/media';
  
  static const String whatsappConversations = '$baseUrl/v1/whatsapp/conversations';
  static const String whatsappMessages = '$baseUrl/v1/whatsapp/conversations'; // + /:conversationId/messages
  static const String whatsappSendText = '$baseUrl/v1/whatsapp/messages/send';
  static const String whatsappSendMedia = '$baseUrl/v1/whatsapp/messages/media';

  // AI Chatbot status toggle
  static const String conversationOff = '$baseUrl/conversation-off'; // + /:conversationId
  static const String conversationOffHandoff = '$baseUrl/conversation-off/handoff';
}
