import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_stat_card.dart';
import 'package:roberto/features/Subscription/widget/custom_planbilling.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Management',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage plans, billing, and subscriptions',
                    style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),
        // ── Stat Cards ──────────────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final cards = [
              CustomStatCard(
                label: 'MRR',
                value: '\$8.9K',
                iconPath: "assets/MRR.svg",
              ),
              CustomStatCard(
                label: 'ARR',
                value: '\$107K',
                iconPath: "assets/ARR.svg",
              ),
              CustomStatCard(
                label: 'Active Subs',
                value: '47',
                iconPath: "assets/person.svg",
              ),
            ];
            return isWide
                ? Row(
              children: cards
                  .map((c) =>
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: cards.indexOf(c) < 2 ? 16 : 0),
                      child: c,
                    ),
                  ))
                  .toList(),
            )
                : Column(
              children: cards
                  .map((c) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: c,
                  ))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        CustomPlanbilling(),
      ],
    );
  }
}