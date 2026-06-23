import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'theme_controller.dart';
import 'app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/core/services/local_storage_service.dart';
import 'package:roberto/features/WhatsAppCampaigns/data/repositories/campaign_repository.dart';
import 'package:roberto/features/WhatsAppCampaigns/bloc/campaign_bloc.dart';
import 'package:roberto/features/management/data/repositories/management_repository.dart';
import 'package:roberto/features/management/bloc/management_bloc.dart';
import 'package:roberto/features/businesssubscription/data/repositories/business_subscription_repository.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_bloc.dart';
import 'package:roberto/features/CRM/data/repositories/crm_repository.dart';
import 'package:roberto/features/CRM/bloc/crm_bloc.dart';
import 'package:roberto/features/Auth/data/repositories/auth_repository.dart';
import 'package:roberto/features/Auth/bloc/auth_bloc.dart';
import 'package:roberto/features/Auth/bloc/forgot_password_bloc.dart';
import 'package:roberto/features/Overview/data/repositories/overview_repository.dart';
import 'package:roberto/features/Overview/bloc/overview_bloc.dart';
import 'package:roberto/features/Subscription/data/repositories/subscription_repository.dart';
import 'package:roberto/features/Subscription/bloc/subscription_bloc.dart';
import 'package:roberto/features/Settings/data/repositories/profile_repository.dart';
import 'package:roberto/features/Settings/bloc/profile_bloc.dart';
import 'package:roberto/features/notification/data/repositories/notification_repository.dart';
import 'package:roberto/features/notification/bloc/notification_bloc.dart';
import 'package:roberto/features/Tenant Management /data/repositories/tenant_repository.dart';
import 'package:roberto/features/Tenant Management /bloc/tenant_bloc.dart';
import 'package:roberto/features/AiAgent/data/repositories/agent_training_repository.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_bloc.dart';
import 'package:roberto/features/Pricing/data/repositories/pricing_repository.dart';
import 'package:roberto/features/Pricing/bloc/pricing_bloc.dart';

class Roberto extends StatelessWidget {
  const Roberto({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<NetworkClient>(
              create: (context) => NetworkClient(
                onUnAuthorize: () {
                  LocalStorageService.clearTokens();
                },
                commonHeaders: () {
                  final token = LocalStorageService.accessToken;
                  if (token != null && token.isNotEmpty) {
                    return {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                      'ngrok-skip-browser-warning': 'true',
                    };
                  }
                  return {
                    'Content-Type': 'application/json',
                    'ngrok-skip-browser-warning': 'true',
                  };
                },
              ),
            ),
            RepositoryProvider<AuthRepository>(
              create: (context) => AuthRepository(
                networkClient: context.read<NetworkClient>(),
              ),
            ),
            RepositoryProvider<CampaignRepository>(
              create: (context) => CampaignRepository(networkClient: context.read<NetworkClient>()),
            ),
            RepositoryProvider<ManagementRepository>(
              create: (context) => ManagementRepository(networkClient: context.read<NetworkClient>()),
            ),
            RepositoryProvider<BusinessSubscriptionRepository>(
              create: (context) => BusinessSubscriptionRepository(networkClient: context.read<NetworkClient>()),
            ),
            RepositoryProvider<OverviewRepository>(
              create: (context) => OverviewRepository(
                networkClient: context.read<NetworkClient>(),
              ),
            ),
            RepositoryProvider<SubscriptionRepository>(
              create: (context) => SubscriptionRepository(
                networkClient: context.read<NetworkClient>(),
              ),
            ),
            RepositoryProvider<ProfileRepository>(
              create: (context) => ProfileRepository(
                networkClient: context.read<NetworkClient>(),
              ),
            ),
            RepositoryProvider<NotificationRepository>(
              create: (context) => NotificationRepository(
                networkClient: context.read<NetworkClient>(),
              ),
            ),
            RepositoryProvider<TenantRepository>(
              create: (context) => TenantRepository(
                networkClient: context.read<NetworkClient>(),
              ),
            ),
            RepositoryProvider<AgentTrainingRepository>(
              create: (context) => AgentTrainingRepository(),
            ),
            RepositoryProvider<CrmRepository>(
              create: (context) => CrmRepository(
                networkClient: context.read<NetworkClient>(),
              ),
            ),
            RepositoryProvider<PricingRepository>(
              create: (context) => PricingRepository(
                networkClient: context.read<NetworkClient>(),
              ),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(
                  authRepository: context.read<AuthRepository>(),
                ),
              ),
              BlocProvider<ForgotPasswordBloc>(
                create: (context) => ForgotPasswordBloc(
                  authRepository: context.read<AuthRepository>(),
                ),
              ),
              BlocProvider<CampaignBloc>(
                create: (context) => CampaignBloc(
                  campaignRepository: context.read<CampaignRepository>(),
                ),
              ),
              BlocProvider<ManagementBloc>(
                create: (context) => ManagementBloc(
                  repository: context.read<ManagementRepository>(),
                ),
              ),
              BlocProvider<BusinessSubscriptionBloc>(
                create: (context) => BusinessSubscriptionBloc(
                  repository: context.read<BusinessSubscriptionRepository>(),
                ),
              ),
              BlocProvider<OverviewBloc>(
                create: (context) => OverviewBloc(
                  overviewRepository: context.read<OverviewRepository>(),
                ),
              ),
              BlocProvider<SubscriptionBloc>(
                create: (context) => SubscriptionBloc(
                  subscriptionRepository: context.read<SubscriptionRepository>(),
                ),
              ),
              BlocProvider<ProfileBloc>(
                create: (context) => ProfileBloc(
                  profileRepository: context.read<ProfileRepository>(),
                ),
              ),
              BlocProvider<NotificationBloc>(
                create: (context) => NotificationBloc(
                  notificationRepository: context.read<NotificationRepository>(),
                ),
              ),
              BlocProvider<TenantBloc>(
                create: (context) => TenantBloc(
                  tenantRepository: context.read<TenantRepository>(),
                ),
              ),
              BlocProvider<AgentTrainingBloc>(
                create: (context) => AgentTrainingBloc(
                  repository: context.read<AgentTrainingRepository>(),
                ),
              ),
              BlocProvider<CrmBloc>(
                create: (context) => CrmBloc(
                  crmRepository: context.read<CrmRepository>(),
                ),
              ),
              BlocProvider<PricingBloc>(
                create: (context) => PricingBloc(
                  pricingRepository: context.read<PricingRepository>(),
                ),
              ),
            ],
            child: MaterialApp(
              title: "MATRIX AI",
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeController.themeMode,
              onGenerateRoute: Routes.generateRoute,
              initialRoute: Routes.login,
            ),
          ),
        );
      },
    );
  }
}