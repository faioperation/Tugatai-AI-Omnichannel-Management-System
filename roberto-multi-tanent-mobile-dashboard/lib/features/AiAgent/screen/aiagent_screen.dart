import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/features/AiAgent/widget/custom_agent.dart';
import 'package:roberto/features/AiAgent/widget/system_prompt_view.dart';
import 'package:roberto/features/AiAgent/widget/training_data_view.dart';

class AiagentScreen extends StatefulWidget {
  const AiagentScreen({super.key});

  @override
  State<AiagentScreen> createState() => _AiagentScreenState();
}

class _AiagentScreenState extends State<AiagentScreen> {
  int _selectedTab = 0; // 0 = System Prompt, 1 = Training Data

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
                    'AI Agent Management',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configure and train your AI assistant',
                    style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // AI Agent Status Card
        const CustomAgent(),
        const SizedBox(height: 24),

        // Toggle Tab Bar
        _buildToggleTabs(),
        const SizedBox(height: 24),

        // Tab Content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _selectedTab == 0
              ? const SystemPromptView(key: ValueKey('system'))
              : const TrainingDataView(key: ValueKey('training')),
        ),
      ],
    );
  }

  Widget _buildToggleTabs() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(
            index: 0,
            iconPath: 'assets/system.svg',
            label: 'System Prompt',
          ),
          _buildTab(
            index: 1,
            iconPath: 'assets/data.svg',
            label: 'Training Data',
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required String iconPath,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isActive ? Colors.white : theme.textTheme.bodyMedium?.color ?? Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.white : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
