import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Subscription/widget/custom_plan.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_bloc.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_event.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/common/user_role.dart';

class CustomPlans extends StatefulWidget {
  final UserRole role;
  const CustomPlans({super.key, this.role = UserRole.businessOwner});

  @override
  State<CustomPlans> createState() => _CustomPlansState();
}

class _CustomPlansState extends State<CustomPlans> {
  bool _isYearly = false;

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

  Widget _buildBillingToggle(ThemeData theme, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _isYearly = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: !_isYearly ? AppColor.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Monthly",
                  style: TextStyle(
                    color: !_isYearly ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _isYearly = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: _isYearly ? AppColor.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      "Yearly",
                      style: TextStyle(
                        color: _isYearly ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "10% Off",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          String? activePlanSlug;
          bool isExpired = false;
          String expiredBillingCycle = "monthly";
          String expiredPlanId = "";

          if (state.subscriptions.isNotEmpty) {
            final sub = state.subscriptions.first;
            isExpired = sub.isExpired;
            expiredBillingCycle = sub.billingCycle;
            if (sub.plan != null) {
              expiredPlanId = sub.plan!.id;
              if (!isExpired) {
                activePlanSlug = sub.plan!.slug.toLowerCase();
              }
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isExpired && widget.role == UserRole.branchManager)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
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
              if (isExpired && widget.role == UserRole.businessOwner)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Your business subscription has expired. Please renew your plan to continue using the platform.",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          context.read<BusinessSubscriptionBloc>().add(
                                CreateCheckoutSessionRequested(
                                  planId: expiredPlanId,
                                  billingCycle: expiredBillingCycle,
                                ),
                              );
                        },
                        child: const Text("Renew Plan"),
                      ),
                    ],
                  ),
                ),
              _buildBillingToggle(theme, isDark),
              _buildStandardPlans(context, activePlanSlug: activePlanSlug),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStandardPlans(BuildContext context, {String? activePlanSlug}) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;
    final bool isTablet = width > 600;

    final plansData = [
      {
        "id": "cmrrkvd1z000006mhsrkki2js",
        "title": "CONNECT",
        "slug": "connect",
        "subtitle": "Best for businesses getting started with AI automation",
        "price": _isYearly ? "\$10800" : "\$1000",
        "iconPath": "assets/half.svg",
        "features": [
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
      },
      {
        "id": "cmrrkx6jv000m06mhh8l499hu",
        "title": "CONVERT",
        "slug": "convert",
        "subtitle": "Best for growing businesses that need more leads, bookings, and automation",
        "price": _isYearly ? "\$13500" : "\$1250",
        "iconPath": "assets/full.svg",
        "features": [
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
      },
      {
        "id": "cmrrkydh7001006mh5zwbiej3",
        "title": "CONTROL",
        "slug": "control",
        "subtitle": "Best for high-volume teams and serious businesses",
        "price": _isYearly ? "\$22356" : "\$2070",
        "iconPath": "assets/enter.svg",
        "features": [
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
      },
    ];

    final List<Widget> planWidgets = plansData.map((data) {
      final String planId = data["id"] as String;
      final String slug = data["slug"] as String;
      final bool isActive = activePlanSlug != null && activePlanSlug == slug;

      return CustomPlan(
        title: data["title"] as String,
        subtitle: data["subtitle"] as String,
        price: data["price"] as String,
        iconPath: data["iconPath"] as String,
        features: List<String>.from(data["features"] as List),
        billingPeriod: _isYearly ? '/year' : '/month',
        buttonText: isActive ? "Plan Active" : "Upgrade",
        onButtonPressed: isActive
            ? null
            : () {
                context.read<BusinessSubscriptionBloc>().add(
                      CreateCheckoutSessionRequested(
                        planId: planId,
                        billingCycle: _isYearly ? "yearly" : "monthly",
                      ),
                    );
              },
      );
    }).toList();

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: planWidgets
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: planWidgets[0]),
              const SizedBox(width: 16),
              Expanded(child: planWidgets[1]),
            ],
          ),
          const SizedBox(height: 16),
          planWidgets[2],
        ],
      );
    } else {
      return Column(
        children: planWidgets
            .map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: p,
                ))
            .toList(),
      );
    }
  }
}