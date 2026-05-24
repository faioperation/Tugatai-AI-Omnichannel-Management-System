import 'package:flutter/material.dart';
import 'package:roberto/features/Inbox/widget/chat_list.dart';
import 'package:roberto/features/Inbox/widget/chat_view.dart';
import 'package:roberto/features/Inbox/widget/chat_details.dart';

// Breakpoints
const double _kDesktop = 900;
const double _kTablet = 650;

class InboxScreen extends StatefulWidget {
  final bool isSystemOwner;
  const InboxScreen({super.key, this.isSystemOwner = false});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool _showChatViewOnMobile = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _kDesktop;
        final isTablet = constraints.maxWidth >= _kTablet && constraints.maxWidth < _kDesktop;
        final isMobile = constraints.maxWidth < _kTablet;

        return SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Inbox",
                style: TextStyle(
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Manage all your customer conversations in one place",
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),
              
              // Chat UI Container
              Container(
                // Using a relative height for desktop/tablet, fixed comfortable height for mobile
                height: isMobile ? 650 : MediaQuery.of(context).size.height > 600 ? MediaQuery.of(context).size.height - 220 : 600,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: isDesktop 
                      ? Row(
                          children: [
                            // Desktop: split into 3 panes
                            Expanded(flex: 3, child: ChatList(
                              onChatSelected: (_) {},
                            )),
                            const VerticalDivider(width: 1, thickness: 1),
                            Expanded(flex: 5, child: ChatView(onBack: null)),
                            const VerticalDivider(width: 1, thickness: 1),
                            const Expanded(flex: 3, child: ChatDetails()),
                          ],
                        )
                      : isTablet
                          ? Row(
                              children: [
                                // Tablet: show list and view
                                Expanded(flex: 3, child: ChatList(
                                  onChatSelected: (_) {},
                                )),
                                const VerticalDivider(width: 1, thickness: 1),
                                Expanded(flex: 5, child: ChatView(onBack: null)),
                              ],
                            )
                          : Column(
                              children: [
                                // Mobile: toggle between list and view
                                if (!_showChatViewOnMobile)
                                  Expanded(
                                    child: ChatList(
                                      onChatSelected: (index) {
                                        setState(() {
                                          _showChatViewOnMobile = true;
                                        });
                                      },
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: ChatView(
                                      onBack: () {
                                        setState(() {
                                          _showChatViewOnMobile = false;
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
