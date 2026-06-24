import 'package:flutter/material.dart';
import 'package:roberto/common/custom_search.dart';

class CustomOrder extends StatelessWidget {
  const CustomOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 🔍 Search Field
          CustomSearch(),

          const SizedBox(width: 12),

          // 📊 Status Dropdown
          _buildDropdown("All status"),

          const SizedBox(width: 12),

          // ⏱ Time Dropdown
          _buildDropdown("All time"),
        ],
      ),
    );
  }

  Widget _buildDropdown(String title) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}