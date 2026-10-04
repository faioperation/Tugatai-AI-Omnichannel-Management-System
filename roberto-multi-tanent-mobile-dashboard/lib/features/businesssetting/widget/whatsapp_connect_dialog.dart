import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/businesssetting/bloc/social_media_bloc.dart';
import 'package:roberto/features/businesssetting/bloc/social_media_event.dart';
import 'package:roberto/features/businesssetting/data/repositories/social_media_repository.dart';

class WhatsAppConnectDialog extends StatefulWidget {
  final String branchId;
  const WhatsAppConnectDialog({Key? key, required this.branchId}) : super(key: key);

  @override
  State<WhatsAppConnectDialog> createState() => _WhatsAppConnectDialogState();
}

class _WhatsAppConnectDialogState extends State<WhatsAppConnectDialog> {
  int _currentStep = 0; // 0: Select Option, 1: QR Code View
  bool _isLoading = false;
  String? _instanceName;
  String? _qrCodeBase64;
  String? _errorMessage;
  Timer? _statusTimer;
  bool _isConnected = false;

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startQrFlow() async {
    setState(() {
      _currentStep = 1;
      _isLoading = true;
      _errorMessage = null;
      _qrCodeBase64 = null;
    });

    try {
      final repo = context.read<SocialMediaRepository>();
      final res = await repo.connectWhatsAppQr(widget.branchId);

      if (res.isNotEmpty && res['instanceName'] != null) {
        _instanceName = res['instanceName'];
        final rawQr = res['qrCode'] as String?;
        if (rawQr != null) {
          _qrCodeBase64 = _cleanBase64(rawQr);
        }

        setState(() {
          _isLoading = false;
        });

        _startPollingStatus();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to initialize QR code. Please check server connection.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  String _cleanBase64(String raw) {
    if (raw.contains(',')) {
      return raw.split(',').last;
    }
    return raw;
  }

  void _startPollingStatus() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_instanceName == null || !mounted) return;

      try {
        final repo = context.read<SocialMediaRepository>();
        final statusRes = await repo.getWhatsAppQrStatus(_instanceName!);

        if (!mounted) return;

        if (statusRes['connected'] == true) {
          timer.cancel();
          setState(() {
            _isConnected = true;
          });

          // Refresh social media state in main screen
          context.read<SocialMediaBloc>().add(CheckSocialMediaStatus(widget.branchId));

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('WhatsApp successfully connected!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        } else if (statusRes['qrCode'] != null) {
          final updatedQr = _cleanBase64(statusRes['qrCode']);
          if (updatedQr != _qrCodeBase64) {
            setState(() {
              _qrCodeBase64 = updatedQr;
            });
          }
        }
      } catch (e) {
        // silently ignore transient network polling errors
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.scaffoldBackgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Color(0xFF25D366), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentStep == 0 ? "Connect WhatsApp" : "Scan WhatsApp QR Code",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentStep == 0
                            ? "Choose your preferred connection method"
                            : "Scan with WhatsApp on your phone",
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_currentStep == 0) _buildOptionSelection(theme, isDark),
            if (_currentStep == 1) _buildQrView(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSelection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Option 1: QR Code Connect
        _buildChoiceCard(
          theme: theme,
          isDark: isDark,
          icon: Icons.qr_code_2_rounded,
          iconColor: const Color(0xFF25D366),
          title: "Scan QR Code (Recommended)",
          badgeText: "Instant • Keep Phone App",
          badgeColor: const Color(0xFF25D366),
          subtitle:
              "Link directly via WhatsApp Web on your phone. Keep your WhatsApp Business mobile app active.",
          onTap: _startQrFlow,
        ),
        const SizedBox(height: 14),

        // Option 2: Meta Cloud API
        _buildChoiceCard(
          theme: theme,
          isDark: isDark,
          icon: Icons.cloud_done_rounded,
          iconColor: Colors.blueAccent,
          title: "Official Meta Cloud API",
          badgeText: "Enterprise • Facebook Login",
          badgeColor: Colors.blueAccent,
          subtitle:
              "Connect via Facebook Embedded Signup. Official WhatsApp Business Cloud API.",
          onTap: () {
            Navigator.of(context).pop();
            context.read<SocialMediaBloc>().add(ConnectWhatsApp(widget.branchId));
          },
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.12),
            width: 1.5,
          ),
          color: isDark ? theme.cardColor.withOpacity(0.4) : const Color(0xFFF9FAFB),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(ThemeData theme, bool isDark) {
    if (_isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF25D366), size: 64),
            const SizedBox(height: 16),
            Text(
              "WhatsApp Connected!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your WhatsApp account is successfully linked with AI automated replies.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.hintColor),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: const Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF25D366)),
            SizedBox(height: 16),
            Text("Generating live QR code...", style: TextStyle(fontSize: 13)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              "Connection Error",
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _startQrFlow,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // QR Code Display Container
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _qrCodeBase64 != null
                ? Image.memory(
                    base64Decode(_qrCodeBase64!),
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: Text("Error rendering QR", style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  )
                : const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF25D366)),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Scanning Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How to connect:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              _buildStepRow("1", "Open WhatsApp on your phone"),
              _buildStepRow("2", "Tap Menu (⋮) or Settings > Linked Devices"),
              _buildStepRow("3", "Tap 'Link a Device' and point your camera at this QR code"),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                _statusTimer?.cancel();
                setState(() {
                  _currentStep = 0;
                });
              },
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text("Back"),
            ),
            TextButton.icon(
              onPressed: _startQrFlow,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Refresh QR"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2, right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11.5, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
