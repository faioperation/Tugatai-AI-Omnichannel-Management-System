import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/businesssubscription/widget/subscription_row.dart';
import 'package:roberto/features/Tenant%20Management%20/widget/custom_headder.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_bloc.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_event.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_state.dart';
import 'package:roberto/features/businesssubscription/data/models/business_subscription_model.dart';
import 'package:intl/intl.dart';

class CustomHistory extends StatefulWidget {
  const CustomHistory({super.key});

  @override
  State<CustomHistory> createState() => _CustomHistoryState();
}

class _CustomHistoryState extends State<CustomHistory> {
  @override
  void initState() {
    super.initState();
    context.read<BusinessSubscriptionBloc>().add(FetchMySubscriptionRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;
    final bool isMobile = width <= 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Billing History",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "View all past transactions and invoices",
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),

              // EXPORT BUTTON
              InkWell(
                onTap: () {
                  print("Export clicked");
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerTheme.color ?? const Color(0xffEEEEEE),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download, size: 18, color: theme.colorScheme.onSurface),
                      if (!isMobile) ...[
                        const SizedBox(width: 6),
                        Text(
                          "Export",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          BlocBuilder<BusinessSubscriptionBloc, BusinessSubscriptionState>(
            builder: (context, state) {
              if (state is BusinessSubscriptionLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BusinessSubscriptionLoaded) {
                // Flatten all invoices from all subscriptions
                final allInvoices = <Map<String, dynamic>>[];
                for (var sub in state.subscriptions) {
                  for (var invoice in sub.invoices) {
                    allInvoices.add({
                      'invoice': invoice,
                      'planName': sub.plan?.name ?? 'Unknown Plan',
                      'expireDate': sub.endDate,
                    });
                  }
                }

                if (allInvoices.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("No billing history found"),
                    ),
                  );
                }

                return isDesktop ? _buildDesktopTable(allInvoices) : _buildMobileList(allInvoices);
              } else if (state is BusinessSubscriptionError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(state.message, style: const TextStyle(color: Colors.red)),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<Map<String, dynamic>> invoicesData) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surface : AppColor.secondary,
                border: Border(
                  bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE)),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: CustomHeadder(label: 'Billing Date')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Plan')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Subscription Pricing')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Expire Date')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Status')),
                  Expanded(flex: 2, child: CustomHeadder(label: 'Actions')),
                ],
              ),
            ),
            _buildRows(invoicesData: invoicesData, isMobile: false),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(List<Map<String, dynamic>> invoicesData) {
    return _buildRows(invoicesData: invoicesData, isMobile: true);
  }

  Widget _buildRows({required List<Map<String, dynamic>> invoicesData, required bool isMobile}) {
    return Column(
      children: invoicesData.map((data) {
        final invoice = data['invoice'] as InvoiceModel;
        final planName = data['planName'] as String;
        final expireDate = data['expireDate'] as DateTime?;

        String formattedDate = invoice.createdAt != null 
            ? DateFormat('MMM d, yyyy').format(invoice.createdAt!) 
            : 'N/A';
        
        String formattedExpireDate = expireDate != null 
            ? DateFormat('MMM d, yyyy').format(expireDate) 
            : 'N/A';

        // Fix casing for Status to capitalize the first letter
        String displayStatus = invoice.status;
        if (displayStatus.isNotEmpty) {
          displayStatus = displayStatus[0].toUpperCase() + displayStatus.substring(1).toLowerCase();
        }

        // Capitalize billing cycle and format price
        String displayCycle = invoice.billingCycle;
        if (displayCycle.isNotEmpty) {
          displayCycle = displayCycle[0].toUpperCase() + displayCycle.substring(1).toLowerCase();
        }
        String displayPrice = "\$${invoice.amount}/$displayCycle";

        return SubscriptionRow(
          date: formattedDate,
          plan: planName,
          price: displayPrice,
          expireDate: formattedExpireDate,
          status: displayStatus,
          invoiceUrl: invoice.invoiceUrl,
          isMobile: isMobile,
        );
      }).toList(),
    );
  }
}
