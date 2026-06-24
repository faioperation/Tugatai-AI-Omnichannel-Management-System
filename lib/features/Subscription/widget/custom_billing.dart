import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Subscription/data/models/subscription_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomBilling extends StatelessWidget {
  final List<BillingHistoryModel>? billingHistory;

  const CustomBilling({super.key, this.billingHistory});

  Future<void> _downloadInvoice(String url) async {
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final items = billingHistory ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header
          width < 600
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Billing History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.download,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      label: const Text("Export History"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Billing History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "View all past transactions and invoices",
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.download,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      label: const Text("Export"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),

          if (width > 800) ...[
            const SizedBox(height: 16),
            // 🔹 Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light ? AppColor.secondary : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: _Header("Date")),
                  Expanded(flex: 3, child: _Header("Description")),
                  Expanded(flex: 3, child: _Header("Client")),
                  Expanded(flex: 2, child: _Header("Amount")),
                  Expanded(flex: 2, child: _Header("Status")),
                  Expanded(flex: 1, child: _Header("Actions")),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 🔹 Table Rows
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text("No billing history found.")),
              )
            else
              Column(
                children: items.map((item) {
                  final dateStr = item.date != null ? DateFormat('MMM d, yyyy').format(item.date!) : "N/A";
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(dateStr)),
                        Expanded(flex: 3, child: Text(item.description)),
                        Expanded(flex: 3, child: Text(item.client)),
                        Expanded(flex: 2, child: Text("\$${item.amount.toStringAsFixed(2)}")),
                        Expanded(
                          flex: 2,
                          child: _StatusBadge(status: item.status),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.download, size: 18),
                            onPressed: () => _downloadInvoice(item.invoiceUrl),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ] else ...[
            const SizedBox(height: 24),
            // 🔹 Mobile Cards
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text("No billing history found.")),
              )
            else
              Column(
                children: items.map((item) => _buildMobileCard(context, item)).toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, BillingHistoryModel item) {
    final dateStr = item.date != null ? DateFormat('MMM d, yyyy').format(item.date!) : "N/A";
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              _StatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Client: ${item.client}",
            style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${item.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => _downloadInvoice(item.invoiceUrl),
                icon: const Icon(Icons.download, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🔹 Header Text
class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// 🔹 Status Badge
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPaid = status == "Paid";

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paidBg = isDark ? const Color(0xff064E3B) : const Color(0xffD1FAE5);
    final unpaidBg = isDark ? const Color(0xff450A0A) : const Color(0xffFEE2E2);
    final paidText = isDark ? const Color(0xffD1FAE5) : const Color(0xff065F46);
    final unpaidText = isDark ? const Color(0xffFEE2E2) : const Color(0xff991B1B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? paidBg : unpaidBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPaid ? paidText : unpaidText,
        ),
      ),
    );
  }
}