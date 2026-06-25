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
    final wabaIdController = TextEditingController();
    final phoneNumberIdController = TextEditingController();
    final phoneNumberController = TextEditingController();
    final accessTokenController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 420,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E222D).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColor.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/whatsapp.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Connect WhatsApp',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Enter your WhatsApp Business credentials to sync conversations instantly.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),

                            _buildTextField(context, wabaIdController, 'WABA ID', Icons.badge_outlined),
                            const SizedBox(height: 16),
                            _buildTextField(context, phoneNumberIdController, 'Phone Number ID', Icons.phone_android_outlined),
                            const SizedBox(height: 16),
                            _buildTextField(context, phoneNumberController, 'Phone Number', Icons.phone_outlined),
                            const SizedBox(height: 16),
                            _buildTextField(context, accessTokenController, 'WhatsApp Access Token', Icons.key_outlined),
                            
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
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
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Connect Account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: AppColor.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColor.primary, fontSize: 14, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xFF151821),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
        ),
      ),
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
