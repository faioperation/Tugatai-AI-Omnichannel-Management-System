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

  void _showWhatsAppDialog(BuildContext context) {
    final theme = Theme.of(context);
    final wabaIdController = TextEditingController();
    final phoneNumberIdController = TextEditingController();
    final phoneNumberController = TextEditingController();
    final accessTokenController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final width = MediaQuery.of(context).size.width;
        final isMobile = width < 600;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: theme.cardColor,
          child: Container(
            width: isMobile ? width * 0.95 : 600,
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connect WhatsApp',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter your WhatsApp Business credentials to sync conversations instantly.',
                              style: TextStyle(fontSize: 14, color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                
                // Form body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text('WABA ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        CustomTextfield(
                          controller: wabaIdController, 
                          hintText: 'Enter WABA ID',
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        Text('Phone Number ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        CustomTextfield(
                          controller: phoneNumberIdController, 
                          hintText: 'Enter Phone Number ID',
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        Text('Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        CustomTextfield(
                          controller: phoneNumberController, 
                          hintText: 'Enter Phone Number',
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
                        ),
                        const SizedBox(height: 16),

                        Text('WhatsApp Access Token', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        CustomTextfield(
                          controller: accessTokenController, 
                          hintText: 'Enter Access Token',
                          textInputAction: TextInputAction.done,
                          validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                // Footer
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          
                          if (widget.branchId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a branch first from the sidebar')),
                            );
                            return;
                          }

                          context.read<SocialMediaBloc>().add(
                            ConnectWhatsAppEvent(
                              branchId: widget.branchId,
                              wabaId: wabaIdController.text,
                              phoneNumberId: phoneNumberIdController.text,
                              phoneNumber: phoneNumberController.text,
                              accessToken: accessTokenController.text,
                            ),
                          );

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Connect Account', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                                    _showWhatsAppDialog(context);
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
