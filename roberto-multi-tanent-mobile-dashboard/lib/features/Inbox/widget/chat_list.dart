import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/app/app_color.dart';

class ChatList extends StatefulWidget {
  final void Function(int index)? onChatSelected;

  const ChatList({super.key, this.onChatSelected});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  int _activeChatIndex = 0;
  int _activeFilterIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardTheme.color,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Filter section
          _buildFilterItem(-1, null, "All", "45"),
          
          // Social Filters
          _buildFilterItem(0, "assets/facebook.svg", "Facebook", "15"),
          _buildFilterItem(1, "assets/instagram.svg", "Instagram", "20"),
          _buildFilterItem(2, "assets/whatsapp.svg", "WhatsApp", "10"),
          
          const Divider(height: 16),
          
          // Chat list
          Expanded(
            child: ListView(
              children: [
                _buildChatListItem(0, "R", "Roberto", "2m ago", "Hi, I'd like to know more about...", "assets/facebook.svg"),
                _buildChatListItem(1, "MC", "Michael Cher", "15m ago", "Thank you for the quick response!", "assets/whatsapp.svg"),
                _buildChatListItem(2, "EW", "Emma Wilso", "1h ago", "Can I schedule a booking for", "assets/instagram.svg"),
                _buildChatListItem(3, "DB", "David Brow", "2h ago", "What are your business hours?", "assets/facebook.svg"),
                _buildChatListItem(4, "LA", "Lisa Andersor", "3h ago", "I received my order, it's perfect!", "assets/whatsapp.svg"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(int index, String? iconPath, String title, String count) {
    bool isActive = _activeFilterIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeFilterIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          decoration: isActive
              ? BoxDecoration(
                  color: AppColor.primary, // AppColor.primary
                  borderRadius: BorderRadius.circular(24),
                )
              : null,
          padding: EdgeInsets.symmetric(
              horizontal: isActive ? 16 : 0, vertical: isActive ? 8 : 8),
          child: Row(
            children: [
              if (iconPath != null) ...[
                SvgPicture.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (isActive)
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light ? const Color(0xffF3F4F6) : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatListItem(int index, String initials, String name, String time, String preview, String socialIconPath) {
    bool isActive = _activeChatIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeChatIndex = index;
        });
        if (widget.onChatSelected != null) {
          widget.onChatSelected!(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isActive ? (Theme.of(context).brightness == Brightness.light ? const Color(0xffFEE2E2) : Theme.of(context).colorScheme.primary.withOpacity(0.2)) : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      socialIconPath,
                      width: 14,
                      height: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
