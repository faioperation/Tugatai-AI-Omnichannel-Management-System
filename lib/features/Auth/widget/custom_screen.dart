
import 'package:flutter/material.dart';


class CustomScreen extends StatefulWidget {
  final Widget child;

  const CustomScreen({
    super.key,
    required this.child,
  });

  @override
  State<CustomScreen> createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 400;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 10 : 16, vertical: isSmall ? 16 : 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.transparent),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: EdgeInsets.all(isSmall ? 20 : 32),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
