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
import 'package:roberto/features/businesssetting/widget/whatsapp_connect_dialog.dart';
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Connect your social media accounts to manage all conversations in one place",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                                isLoading: state.isLoading && !state.isFacebookConnected && !state.isInstagramConnected && !state.isWhatsAppConnected && !state.isGoogleCalendarConnected,
                                onActionPressed: () {
                                  if (state.isWhatsAppConnected) {
                                    if (state.whatsappConnectionType == 'QR_CODE') {
                                      _showWhatsAppQrDisconnectDialog(context, state.whatsappAccountId);
                                    } else if (state.whatsappAccountId != null) {
                                      _showWhatsAppMetaDisconnectDialog(context, state.whatsappAccountId!);
                                    } else {
                                      _showWhatsAppQrDisconnectDialog(context, state.whatsappAccountId);
                                    }
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) => BlocProvider.value(
                                        value: context.read<SocialMediaBloc>(),
                                        child: WhatsAppConnectDialog(branchId: widget.branchId),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 15),
                              CustomMedia(
                                iconPath: 'assets/system.svg',
                                title: 'Google Calendar',
                                subtitle: state.isGoogleCalendarConnected ? 'Connected (${state.googleCalendarEmail ?? ""})' : 'Not Connected',
                                isConnected: state.isGoogleCalendarConnected,
                                isLoading: state.isLoading && !state.isFacebookConnected && !state.isInstagramConnected && !state.isWhatsAppConnected && !state.isGoogleCalendarConnected,
                                onActionPressed: () {
                                  if (state.isGoogleCalendarConnected) {
                                    context.read<SocialMediaBloc>().add(DisconnectGoogleCalendar(widget.branchId));
                                  } else {
                                    context.read<SocialMediaBloc>().add(ConnectGoogleCalendar(widget.branchId));
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Preferences",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: themeController.isDarkMode ? Colors.amber.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              themeController.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: themeController.isDarkMode ? Colors.amber : Colors.blue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dark Mode",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Switch between light and dark system themes",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: themeController.isDarkMode,
                            activeColor: AppColor.primary,
                            onChanged: (value) {
                              themeController.toggleTheme();
                            },
                          ),
                        ],
                      ),
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

  void _showWhatsAppQrDisconnectDialog(BuildContext context, [String? accountId]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).cardColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xff25D366).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/whatsapp.svg',
                      width: 34,
                      height: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Disconnect WhatsApp",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "To disconnect WhatsApp, please log out directly from your phone's WhatsApp app:",
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInstructionStep(
                        number: "1",
                        text: "Open WhatsApp on your mobile phone",
                        context: context,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        number: "2",
                        text: "Go to Settings (or Menu ⋮) > Linked Devices",
                        context: context,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        number: "3",
                        text: "Select this active session and tap 'Log Out'",
                        context: context,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: isDark ? Colors.blue.shade300 : const Color(0xff2563EB),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Once disconnected from your phone, this dashboard will automatically update.",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.blue.shade200 : const Color(0xff1D4ED8),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.read<SocialMediaBloc>().add(CheckSocialMediaStatus(widget.branchId));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          "Check Status",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          final id = accountId ?? context.read<SocialMediaBloc>().state.whatsappAccountId ?? "";
                          context.read<SocialMediaBloc>().add(
                            DisconnectWhatsApp(id, widget.branchId),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Got It",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionStep({
    required String number,
    required String text,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  void _showWhatsAppMetaDisconnectDialog(BuildContext context, String accountId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Disconnect WhatsApp"),
          content: const Text("Are you sure you want to disconnect your WhatsApp Cloud API account?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<SocialMediaBloc>().add(DisconnectWhatsApp(accountId, widget.branchId));
              },
              child: const Text("Disconnect"),
            ),
          ],
        );
      },
    );
  }
}
