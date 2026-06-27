import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:roberto/core/services/local_storage_service.dart';
import 'package:roberto/features/management/bloc/management_bloc.dart';
import 'package:roberto/features/management/bloc/management_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/app/theme_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/features/businesssetting/widget/custom_media.dart';
import 'package:roberto/features/businesssetting/bloc/social_media_bloc.dart';
import 'package:roberto/features/businesssetting/bloc/social_media_event.dart';
import 'package:roberto/features/businesssetting/bloc/social_media_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';

class BusinessownerSettings extends StatefulWidget {
  final String branchId;
  const BusinessownerSettings({super.key, required this.branchId});

  @override
  State<BusinessownerSettings> createState() => _BusinessownerSettingsState();
}

class _BusinessownerSettingsState extends State<BusinessownerSettings> {
  @override
  void initState() {
    super.initState();
    context.read<SocialMediaBloc>().add(CheckSocialMediaStatus(widget.branchId));
  }

  @override
  void didUpdateWidget(BusinessownerSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId) {
      context.read<SocialMediaBloc>().add(CheckSocialMediaStatus(widget.branchId));
    }
  }



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return BlocListener<SocialMediaBloc, SocialMediaState>(
      listenWhen: (previous, current) =>
          previous.redirectUrl != current.redirectUrl || previous.error != current.error,
      listener: (context, state) async {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.redirectUrl != null) {
          final uri = Uri.parse(state.redirectUrl!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch URL')),
            );
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your system preferences and configurations',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
            ),
            child: Row(
              children: [
                // RIGHT COLUMN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/msg.svg",
                            height: 44,
                            width: 44,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "Social Media Connections",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Connect your social media accounts to manage all conversations in one place",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 15),
                      BlocBuilder<SocialMediaBloc, SocialMediaState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              CustomMedia(
                                iconPath: 'assets/facebook.svg',
                                title: 'Facebook',
                                subtitle: state.isFacebookConnected ? 'Connected' : 'Not Connected',
                                isConnected: state.isFacebookConnected,
                                isLoading: state.isLoading && !state.isFacebookConnected && !state.isInstagramConnected && !state.isWhatsAppConnected,
                                onActionPressed: () {
                                  if (state.isFacebookConnected && state.facebookConnectionId != null) {
                                    context.read<SocialMediaBloc>().add(DisconnectFacebook(state.facebookConnectionId!, widget.branchId));
                                  } else {
                                    context.read<SocialMediaBloc>().add(ConnectFacebook(widget.branchId));
                                  }
                                },
                              ),
                              const SizedBox(height: 15),
                              CustomMedia(
                                iconPath: 'assets/instagram.svg',
                                title: 'Instagram',
                                subtitle: state.isInstagramConnected ? 'Connected' : 'Not Connected',
                                isConnected: state.isInstagramConnected,
                                isLoading: state.isLoading && !state.isFacebookConnected && !state.isInstagramConnected && !state.isWhatsAppConnected,
                                onActionPressed: () {
                                  if (state.isInstagramConnected && state.instagramConnectionId != null) {
                                    context.read<SocialMediaBloc>().add(DisconnectInstagram(state.instagramConnectionId!, widget.branchId));
                                  } else {
                                    context.read<SocialMediaBloc>().add(ConnectInstagram(widget.branchId));
                                  }
                                },
                              ),
                              const SizedBox(height: 15),
                              CustomMedia(
                                iconPath: 'assets/whatsapp.svg',
                                title: 'WhatsApp',
                                subtitle: state.isWhatsAppConnected ? 'Connected' : 'Not Connected',
                                isConnected: state.isWhatsAppConnected,
                                isLoading: state.isLoading && !state.isFacebookConnected && !state.isInstagramConnected && !state.isWhatsAppConnected,
                                onActionPressed: () {
                                  if (state.isWhatsAppConnected && state.whatsappAccountId != null) {
                                    context.read<SocialMediaBloc>().add(DisconnectWhatsApp(state.whatsappAccountId!, widget.branchId));
                                  } else {
                                    context.read<SocialMediaBloc>().add(ConnectWhatsApp(widget.branchId));
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // SYSTEM PREFERENCES CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Preferences",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) {
                    return SwitchListTile(
                      title: const Text("Dark Mode"),
                      subtitle: const Text("Switch between light and dark system themes"),
                      value: themeController.isDarkMode,
                      activeThumbColor: AppColor.primary,
                      onChanged: (value) {
                        themeController.toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
