import 'package:flutter/material.dart';

class CustomClientdetails extends StatelessWidget {
  const CustomClientdetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Client Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const Text(
              'View and manage client account information',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 15),

            // Grid fields
            _buildRow('Business Name', 'Fashion Boutique', 'Owner', 'Sarah Johnson'),
            const SizedBox(height: 12),
            _buildRow('Email', 'sarah@fashionboutique.com', 'Phone', '+1 234 567 8901'),
            const SizedBox(height: 12),

            // Plan with badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Plan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xffBEDBFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'half moon',
                          style: TextStyle(fontSize: 12, color: Color(0xff1447E6)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRow('Monthly Revenue', '\$199', 'Joined Date', 'Jan 15, 2026'),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(child: _buildField(l1, v1)),
        Expanded(child: _buildField(l2, v2)),
      ],
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}