import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Subscription/widget/custom_plan.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_bloc.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_event.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_state.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:roberto/common/user_role.dart';

class CustomPlans extends StatefulWidget {
  final UserRole role;
  const CustomPlans({super.key, this.role = UserRole.businessOwner});

  @override
  State<CustomPlans> createState() => _CustomPlansState();
}

class _CustomPlansState extends State<CustomPlans> {
  @override
  void initState() {
    super.initState();
    context.read<BusinessSubscriptionBloc>().add(FetchMySubscriptionRequested());
  }

  Future<void> _launchUrl(String url) async {
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  String _getIconPath(String slug) {
    switch (slug.toLowerCase()) {
      case 'connect':
        return 'assets/half.svg';
      case 'convert':
        return 'assets/full.svg';
      case 'control':
        return 'assets/enter.svg';
      default:
        return 'assets/half.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessSubscriptionBloc, BusinessSubscriptionState>(
      listener: (context, state) {
        if (state is CheckoutSessionSuccess) {
          _launchUrl(state.url);
        } else if (state is BusinessSubscriptionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BusinessSubscriptionLoading || state is CheckoutSessionLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is BusinessSubscriptionLoaded) {
          if (state.subscriptions.isEmpty) {
            return _buildStandardPlans(context);
          }

          final sub = state.subscriptions.first;
          final plan = sub.plan;
          if (plan == null) {
            return const Center(child: Text("No subscription plan details found"));
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sub.isExpired && widget.role == UserRole.branchManager)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Your business subscription has expired. Please inform your owner to renew the subscription to continue using the platform.",
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  CustomPlan(
                    title: plan.name,
                    subtitle: plan.description,
                    price: "\$${plan.monthlyPrice.toInt()}",
                    iconPath: _getIconPath(plan.slug),
                    features: plan.features.map((f) => f.value).toList(),
                    buttonText: sub.isExpired
                        ? (widget.role == UserRole.businessOwner ? "Renew Plan" : "Plan Expired")
                        : "Plan Active",
                    onButtonPressed: (sub.isExpired && widget.role == UserRole.businessOwner)
                        ? () {
                            context.read<BusinessSubscriptionBloc>().add(
                                  CreateCheckoutSessionRequested(
                                    planId: plan.id,
                                    billingCycle: sub.billingCycle,
                                  ),
                                );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStandardPlans(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;
    final bool isTablet = width > 600;

    final plans = [
      const CustomPlan(
        title: "CONNECT",
        subtitle: "Best for businesses getting started with AI automation",
        price: "\$700",
        iconPath: "assets/half.svg",
        features: [
          "2 channels",
          "up to 1,000 chats/month",
          "shared inbox",
          "basic AI instant replies",
          "basic lead capture",
          "basic booking form",
          "limited analytics",
          "no advanced automation",
          "no campaigns",
          "no voice AI",
        ],
      ),
      const CustomPlan(
        title: "CONVERT",
        subtitle: "Best for growing businesses that need more leads, bookings, and automation",
        price: "\$1250",
        iconPath: "assets/full.svg",
        features: [
          "everything in CONNECT, plus:",
          "multi-channel",
          "up to 5,000 chats/month",
          "advanced AI assistant",
          "CRM pipeline",
          "full booking workflow",
          "pricing engine",
          "quote generation",
          "workflow automation",
          "chat summaries",
          "WhatsApp campaigns (basic)",
          "analytics dashboard",
          "AI assist for agents",
        ],
      ),
      const CustomPlan(
        title: "CONTROL",
        subtitle: "Best for high-volume teams and serious businesses",
        price: "\$2050",
        iconPath: "assets/enter.svg",
        features: [
          "everything in CONVERT, plus:",
          "unlimited or high-volume chats",
          "multi-branch / multi-country",
          "advanced workflow automation",
          "advanced campaigns",
          "API integrations",
          "advanced analytics",
          "dedicated onboarding",
          "priority support",
          "voice AI included or as premium add-on",
        ],
      ),
    ];

    if (isDesktop) {
      return Row(
        children: plans
            .map((p) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: p,
                  ),
                ))
            .toList(),
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: plans[0]),
              const SizedBox(width: 16),
              Expanded(child: plans[1]),
            ],
          ),
          const SizedBox(height: 16),
          plans[2],
        ],
      );
    } else {
      return Column(
        children: plans
            .map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: p,
                ))
            .toList(),
      );
    }
  }
}