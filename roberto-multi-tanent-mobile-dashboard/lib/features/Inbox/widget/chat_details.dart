import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Inbox/data/models/inbox_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_bloc.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatDetails extends StatelessWidget {
  final ConversationMod? conversation;

  const ChatDetails({super.key, this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (conversation == null) {
      return Container(
        color: theme.cardTheme.color,
        child: Center(
          child: Text(
            "Select a chat to view summary details",
            style: TextStyle(color: theme.hintColor, fontSize: 13),
          ),
        ),
      );
    }

    final conv = conversation!;
    final summary = conv.chatSummary;
    final intent = summary?.intent?.toLowerCase() ?? 'cold';
    
    // Intent badge color
    Color intentBg = const Color(0xffFEE2E2);
    Color intentFg = Colors.red;
    if (intent == 'hot') {
      intentBg = const Color(0xffFEF3C7);
      intentFg = const Color(0xffD97706);
    } else if (intent == 'warm') {
      intentBg = const Color(0xffDBEAFE);
      intentFg = const Color(0xff2563EB);
    }

    return Container(
      color: theme.cardTheme.color,
      child: Column(
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv.customerName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.customerPhone ?? "No Phone Number",
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                          if (conv.customerPhone != null && conv.customerPhone!.isNotEmpty)
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: conv.customerPhone!));
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Phone number copied"),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    width: 220,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: theme.colorScheme.primary.withOpacity(0.8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: intentBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    intent.toUpperCase(),
                    style: TextStyle(
                      color: intentFg,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Chat summary card
                BlocBuilder<BusinessSubscriptionBloc, BusinessSubscriptionState>(
                  builder: (context, subState) {
                    bool isConnectPlan = false;
                    if (subState is BusinessSubscriptionLoaded && subState.subscriptions.isNotEmpty) {
                      final planSlug = subState.subscriptions.first.plan?.slug.toLowerCase();
                      if (planSlug == 'connect') {
                        isConnectPlan = true;
                      }
                    }

                    if (isConnectPlan) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerTheme.color ?? (isDark ? AppColor.borderDark : AppColor.borderLight)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: const BoxDecoration(
                                  color: AppColor.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(11),
                                    topRight: Radius.circular(11),
                                  ),
                                ),
                                child: const Text(
                                  "Chat summary",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'buy convert or control subscription to get this features',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                                    fontSize: 14,
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (summary?.summary != null && summary!.summary!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.dividerTheme.color ?? (isDark ? AppColor.borderDark : AppColor.borderLight)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: const BoxDecoration(
                                      color: AppColor.primary,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(11),
                                        topRight: Radius.circular(11),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Chat summary",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: summary!.summary!));
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Chat summary copied"),
                                                duration: Duration(seconds: 2),
                                                behavior: SnackBarBehavior.floating,
                                                width: 240,
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(4),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.copy_rounded, size: 13, color: Colors.white),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Copy",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: SelectableText(
                                      summary!.summary!,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (summary != null)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerTheme.color ?? (isDark ? AppColor.borderDark : AppColor.borderLight)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: const BoxDecoration(
                                    color: AppColor.primary,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(11),
                                      topRight: Radius.circular(11),
                                    ),
                                  ),
                                  child: const Text(
                                    "Recent Chat Details",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      _buildFormField(context, "Items", summary!.items ?? "Not specified"),
                                      const SizedBox(height: 16),
                                      _buildFormField(context, "Pickup Area", summary!.pickupArea ?? "Not specified"),
                                      const SizedBox(height: 16),
                                      _buildFormField(context, "Destination", summary!.destination ?? "Not specified"),
                                      const SizedBox(height: 16),
                                      _buildFormField(context, "Weight", summary!.weight ?? "Not specified"),
                                      const SizedBox(height: 16),
                                      _buildFormField(context, "Pickup Date & Time", summary!.pickupDateTime ?? "Not specified"),
                                      const SizedBox(height: 16),
                                      _buildFormField(context, "Current status", summary!.currentStatus),
                                      const SizedBox(height: 16),
                                      _buildFormField(context, "Recent summary", summary!.recentSummary ?? "Not specified"),
                                      const SizedBox(height: 16),
                                      _buildFormField(
                                        context,
                                        "Booking info",
                                        summary!.bookingInfo != null 
                                            ? "Booked: ${summary!.bookingInfo!.booked}, Reference: ${summary!.bookingInfo!.reference ?? 'N/A'}${summary!.bookingInfo!.price != null ? ', Price: \$${summary!.bookingInfo!.price}' : ''}"
                                            : "Not specified",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (summary != null)
                          const SizedBox(height: 24),
                      ],
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

  Widget _buildFormField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isUrl = value.startsWith('http://') || 
                  value.startsWith('https://') || 
                  value.startsWith('www.') ||
                  value.contains('maps.app.goo.gl') ||
                  value.contains('google.com/maps');
    final effectiveUrl = value.startsWith('www.') ? 'https://$value' : value;
    final canCopy = value.isNotEmpty && value != "Not specified";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (canCopy)
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Copied '$label' to clipboard"),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      width: 280,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: theme.colorScheme.primary.withOpacity(0.85),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Copy",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerTheme.color ?? Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: theme.cardTheme.color,
          ),
          child: isUrl
              ? InkWell(
                  onTap: () async {
                    final uri = Uri.parse(effectiveUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: Color(0xff3B82F6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff3B82F6),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
        ),
      ],
    );
  }
}

