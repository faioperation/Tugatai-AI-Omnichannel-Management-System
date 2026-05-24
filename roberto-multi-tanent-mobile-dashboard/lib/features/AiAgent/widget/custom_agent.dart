import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/app/app_color.dart';

class CustomAgent extends StatefulWidget {
  const CustomAgent({super.key});

  @override
  State<CustomAgent> createState() => _CustomAgentState();
}

class _CustomAgentState extends State<CustomAgent> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmall = constraints.maxWidth < 400;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerTheme.color!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(isSmall),
              const SizedBox(height: 7),
              Text(
                "Your AI agent is ready to configure and train.",
                style: TextStyle(fontSize: isSmall ? 12 : 14, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 27),
              _buildStatusSection(isSmall),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(bool isSmall) {
    return Row(
      children: [
          SvgPicture.asset(
            'assets/agent.svg',
            width: isSmall ? 20 : 23,
            height: isSmall ? 20 : 23,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        const SizedBox(width: 8),
        Text(
          "AI Agent Status",
          style: TextStyle(
            fontSize: isSmall ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(bool isSmall) {
    final titleCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AI Agent ",
          style: TextStyle(
            fontSize: isSmall ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          "AI is handling conversations automatically",
          style: TextStyle(
            fontSize: isSmall ? 12 : 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );

    final switchBtn = Transform.scale(
      scale: isSmall ? 0.6 : 0.70,
      child: Switch(
        value: isOn,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: (value) {
          setState(() {
            isOn = value;
          });
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );

    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "AI Agent ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              switchBtn,
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "AI is handling conversations automatically",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleCol,
        switchBtn,
      ],
    );
  }
}
