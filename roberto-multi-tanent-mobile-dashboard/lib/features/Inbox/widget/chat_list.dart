import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Inbox/data/models/inbox_models.dart';

class ChatList extends StatelessWidget {
  final List<ConversationMod> conversations;
  final ConversationMod? selectedConversation;
  final String selectedPlatform;
  final bool isLoading;
  final ValueChanged<String> onPlatformChanged;
  final ValueChanged<ConversationMod> onConversationSelected;

  const ChatList({
    super.key,
    required this.conversations,
    this.selectedConversation,
    required this.selectedPlatform,
    required this.isLoading,
    required this.onPlatformChanged,
    required this.onConversationSelected,
  });

  Widget _buildFilterItem(String platform, String? iconPath, String title, String count, BuildContext context) {
    bool isActive = selectedPlatform == platform;
    return InkWell(
      onTap: () => onPlatformChanged(platform),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          decoration: isActive
              ? BoxDecoration(
                  color: AppColor.primary,
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

  Widget _buildChatListItem(ConversationMod conv, bool isActive, BuildContext context) {
    final initials = conv.customerName.isNotEmpty 
        ? conv.customerName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase()
        : 'S';
    final name = conv.customerName;
    
    String timeStr = 'Now';
    try {
      final parsed = DateTime.tryParse(conv.lastMessageAt);
      if (parsed != null) {
        final diff = DateTime.now().difference(parsed);
        if (diff.inMinutes < 60) {
          timeStr = '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24) {
          timeStr = '${diff.inHours}h ago';
        } else {
          timeStr = '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
        }
      }
    } catch (_) {}
    
    final bool isOutgoing = conv.lastMessageDirection == 'OUTGOING';

    // Build display preview from lastMessage
    String rawPreview = conv.lastMessage.trim();

    // If still empty, show a fallback placeholder
    if (rawPreview.isEmpty) {
      rawPreview = '💬 Message';
    }

    // Add "You: " prefix if it was an outgoing message
    final String preview = isOutgoing ? 'You: $rawPreview' : rawPreview;

    String socialIconPath = 'assets/facebook.svg';
    if (conv.platform == 'instagram') {
      socialIconPath = 'assets/instagram.svg';
    } else if (conv.platform == 'whatsapp') {
      socialIconPath = 'assets/whatsapp.svg';
    }

    return InkWell(
      onTap: () => onConversationSelected(conv),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isActive 
            ? (Theme.of(context).brightness == Brightness.light 
                ? const Color(0xffFEE2E2) 
                : Theme.of(context).colorScheme.primary.withOpacity(0.2)) 
            : Colors.transparent,
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
                      initials.length > 2 ? initials.substring(0, 2) : initials,
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
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
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
                      fontWeight: conv.seen ? FontWeight.normal : FontWeight.w700,
                      color: conv.seen 
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!conv.continueAi) ...[
              const SizedBox(width: 8),
              const Tooltip(
                message: 'AI reply paused - needs human attention',
                child: Icon(
                  Icons.error,
                  color: Color(0xFFB71C1C),
                  size: 25,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Count platform-specific counts if we are in 'all' view
    final allCount = conversations.length.toString();
    
    int mCount = 0;
    int iCount = 0;
    int wCount = 0;
    
    for (var c in conversations) {
      final plat = c.platform.toLowerCase();
      if (plat == 'messenger') mCount++;
      if (plat == 'instagram') iCount++;
      if (plat == 'whatsapp') wCount++;
    }
    
    final messengerCount = mCount.toString();
    final instagramCount = iCount.toString();
    final whatsappCount = wCount.toString();

    final filteredConversations = selectedPlatform == 'all'
        ? conversations
        : conversations.where((c) => c.platform.toLowerCase() == selectedPlatform.toLowerCase()).toList();

    return Container(
      color: theme.cardTheme.color,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildFilterItem('all', null, "All", allCount, context),
          _buildFilterItem('messenger', "assets/facebook.svg", "Facebook", messengerCount, context),
          _buildFilterItem('instagram', "assets/instagram.svg", "Instagram", instagramCount, context),
          _buildFilterItem('whatsapp', "assets/whatsapp.svg", "WhatsApp", whatsappCount, context),
          const Divider(height: 16),
          
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColor.primary))
                : filteredConversations.isEmpty
                    ? Center(child: Text("No conversations", style: TextStyle(color: theme.hintColor)))
                    : ListView.builder(
                        itemCount: filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conv = filteredConversations[index];
                          final isActive = selectedConversation?.id == conv.id;
                          return _buildChatListItem(conv, isActive, context);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
