import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Subscription/bloc/subscription_bloc.dart';
import 'package:roberto/features/Subscription/bloc/subscription_event.dart';
import 'package:roberto/features/Subscription/bloc/subscription_state.dart';
import 'package:roberto/features/Subscription/data/models/subscription_model.dart';
import 'package:flutter/material.dart';
import 'package:roberto/features/TenantManagement%20/widget/custom_stat_card.dart';
import 'package:roberto/features/Subscription/widget/custom_planbilling.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(FetchSubscriptionsRequested());
  }

  @override
  Widget build(BuildContext context) {
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
        // ── Stat Cards & Plan Billing ─────────────────────────────────────────
        BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ));
            } else if (state is SubscriptionError) {
              return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
            } else if (state is SubscriptionLoaded) {
              final data = state.subscriptionData;
              return _buildDashboardContent(context, data);
            }
            return const SizedBox.shrink(); // Initial state
          },
        ),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context, SystemOwnerSubscriptionModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final cards = [
              CustomStatCard(
                label: 'MRR',
                value: '\$${data.mrr.toStringAsFixed(0)}',
                iconPath: "assets/MRR.svg",
              ),
              CustomStatCard(
                label: 'ARR',
                value: '\$${data.arr.toStringAsFixed(0)}',
                iconPath: "assets/ARR.svg",
              ),
              CustomStatCard(
                label: 'Active Subs',
                value: '${data.activeSubs}',
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
        CustomPlanbilling(subscriptionData: data),
      ],
    );
  }
}