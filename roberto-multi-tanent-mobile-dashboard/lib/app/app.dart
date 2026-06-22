import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'theme_controller.dart';
import 'app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/core/services/local_storage_service.dart';
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