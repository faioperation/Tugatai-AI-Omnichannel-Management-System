import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roberto/features/Inbox/data/models/inbox_models.dart';
import 'package:roberto/features/Inbox/data/repositories/inbox_repository.dart';
import 'package:roberto/core/network/api_constants.dart';
import 'package:http/http.dart' show get;
import 'package:url_launcher/url_launcher.dart';
import 'package:roberto/features/Inbox/widget/inline_audio_player.dart';
import 'package:roberto/features/Settings/bloc/profile_bloc.dart';
import 'package:roberto/features/Settings/bloc/profile_state.dart';

class ChatView extends StatefulWidget {
  final ConversationMod? conversation;
  final List<MessageMod> messages;
  final bool isLoading;
  final VoidCallback? onBack;
  final ValueChanged<String> onSendMessage;
  final Function(String path, List<int> bytes, String name) onSendImage;
  final bool isAiOn;
  final ValueChanged<bool> onToggleAi;
  final VoidCallback? onHelpMe;

  const ChatView({
    super.key,
    this.conversation,
    required this.messages,
    required this.isLoading,
    this.onBack,
    required this.onSendMessage,
    required this.onSendImage,
    required this.isAiOn,
    required this.onToggleAi,
    this.onHelpMe,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGeneratingReply = false;

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void didUpdateWidget(covariant ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length || 
        widget.isLoading != oldWidget.isLoading ||
        widget.conversation?.id != oldWidget.conversation?.id) {
      _scrollToBottom();
    }
    if (widget.conversation?.id != oldWidget.conversation?.id) {
      controller.clear();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  String _getBusinessType() {
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        return profileState.user.businessType ?? '';
      } else if (profileState is ProfileUpdateSuccess) {
        return profileState.user.businessType ?? '';
      }
    } catch (_) {}
    return '';
  }

  String _getNormalizedBusinessType() {
    final raw = _getBusinessType();
    if (raw.isEmpty) return 'PARCEL_DELIVERY'; // default fallback
    return raw.toUpperCase().replaceAll(' ', '_');
  }

  Future<void> _generateSuggestedReply() async {
    final convId = widget.conversation?.id;
    if (convId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a conversation first')),
      );
      return;
    }

    setState(() {
      _isGeneratingReply = true;
    });

    try {
      final inboxRepo = context.read<InboxRepository>();
      final subject = _getNormalizedBusinessType();
      final res = await inboxRepo.suggestReply(convId, subject);

      if (!mounted) return;

      if (res['success'] == true) {
        final data = res['data']?['data'];
        if (data != null && data['suggestedReply'] != null) {
          final replyText = data['suggestedReply'] as String;
          setState(() {
            controller.text = replyText;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No suggested reply generated')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to generate suggested reply')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReply = false;
        });
      }
    }
  }

  String? _extractMapUrl(String text) {
    // 1. First try to extract a URL from the text containing maps or google.com
    final regExp = RegExp(r'(https?://[^\s]+)');
    final matches = regExp.allMatches(text);
    for (var match in matches) {
      final url = match.group(0);
      if (url != null && (url.contains('maps') || url.contains('google.com') || url.contains('goo.gl'))) {
        return url;
      }
    }

    // 2. If no URL, try to extract latitude and longitude values
    final latReg = RegExp(r'(?:latitude|lat)\s*:\s*([-\d\.]+)', caseSensitive: false);
    final lngReg = RegExp(r'(?:longitude|lng|long)\s*:\s*([-\d\.]+)', caseSensitive: false);
    
    final latMatch = latReg.firstMatch(text);
    final lngMatch = lngReg.firstMatch(text);
    
    if (latMatch != null && lngMatch != null) {
      final lat = latMatch.group(1);
      final lng = lngMatch.group(1);
      if (lat != null && lng != null) {
        return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      }
    }
    
    return null;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.conversation == null) {
      return Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: theme.hintColor.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                "Select a conversation to start chatting",
                style: TextStyle(fontSize: 16, color: theme.hintColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    final conv = widget.conversation!;
    final initials = conv.customerName.isNotEmpty 
        ? conv.customerName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase()
        : 'S';

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
            ),
            child: Row(
              children: [
                if (widget.onBack != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),

                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials.length > 2 ? initials.substring(0, 2) : initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${conv.platform.toUpperCase()} Chat",
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                if (conv.continueAi == false) ...[
                  _AnimatingHelpMeButton(
                    onPressed: widget.onHelpMe,
                  ),
                  const SizedBox(width: 8),
                ],

                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: widget.isAiOn,
                    onChanged: widget.onToggleAi,
                    activeColor: AppColor.mini,
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColor.primary))
                : widget.messages.isEmpty
                    ? Center(
                        child: Text(
                          "No messages yet. Send a message to start the conversation!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.hintColor),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: widget.messages.length,
                        itemBuilder: (context, index) {
                          final msg = widget.messages[index];

                          // Format time nicely
                          String timeStr = 'Now';
                          try {
                            final parsed = DateTime.tryParse(msg.createdAt);
                            if (parsed != null) {
                              timeStr = "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
                            }
                          } catch (_) {}

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildMessageBubble(
                              msg: msg,
                              time: timeStr,
                              isMe: msg.isMe,
                              context: context,
                            ),
                          );
                        },
                      ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light ? const Color(0xffF3F4F6) : theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      widget.onSendImage(image.path, bytes, image.name);
                    }
                  },
                ),
                const SizedBox(width: 4),
                _isGeneratingReply
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: _generateSuggestedReply,
                        icon: const Icon(Icons.auto_awesome, size: 14, color: Colors.purple),
                        label: const Text('Generate Reply', style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.purple, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: controller,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.send, color: AppColor.primary),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getResolvedMediaUrl(String mediaIdOrUrl) {
    if (mediaIdOrUrl.startsWith('http://') || mediaIdOrUrl.startsWith('https://') || mediaIdOrUrl.startsWith('blob:')) {
      return mediaIdOrUrl;
    }
    final isMediaId = RegExp(r'^\d+$').hasMatch(mediaIdOrUrl);
    if (isMediaId) {
      final baseUrlWithoutApi = ApiConstants.baseUrl.replaceAll('/api', '');
      return '$baseUrlWithoutApi/v1/whatsapp/media/$mediaIdOrUrl';
    }
    final base = ApiConstants.baseUrl.replaceAll('/api', '');
    final path = mediaIdOrUrl.startsWith('/') ? mediaIdOrUrl : '/$mediaIdOrUrl';
    return '$base$path';
  }

  Future<void> _downloadAndOpenMedia(String url, String fileName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading file...'), duration: Duration(seconds: 2)),
      );
      
      final baseHost = Uri.parse(ApiConstants.baseUrl).host;
      final isBackendUrl = url.contains(baseHost) || !url.startsWith('http');
      
      String finalUrl = url;
      if (isBackendUrl && !finalUrl.contains('?download=')) {
        finalUrl = finalUrl.contains('?') ? '$finalUrl&download=true' : '$finalUrl?download=true';
      }

      Map<String, String>? headers;
      if (isBackendUrl) {
        final inboxRepo = context.read<InboxRepository>();
        headers = inboxRepo.networkClient.commonHeaders();
      }
      
      var response = await get(Uri.parse(finalUrl), headers: headers);
      
      // Robust Fallback mechanism if 404 occurs on backend media URL
      if (response.statusCode == 404 && isBackendUrl) {
        final parts = url.split('/');
        final lastPart = parts.isNotEmpty ? parts.last.split('?').first : '';
        final qParam = finalUrl.contains('?download=true') ? '?download=true' : '';
        
        if (RegExp(r'^\d+$').hasMatch(lastPart)) {
           // Try standard v1 endpoint
           final fallbackUrl1 = '${ApiConstants.baseUrl.replaceAll('/api', '')}/v1/whatsapp/media/$lastPart$qParam';
           response = await get(Uri.parse(fallbackUrl1), headers: headers);
           
           if (response.statusCode == 404) {
             // Try api/v1 endpoint
             final fallbackUrl2 = '${ApiConstants.baseUrl.replaceAll('/api', '')}/api/v1/whatsapp/media/$lastPart$qParam';
             response = await get(Uri.parse(fallbackUrl2), headers: headers);
           }
        } else if (url.contains('/v1/')) {
           final fallbackUrl = url.replaceAll('/v1/', '/api/v1/');
           final fUrl = fallbackUrl.contains('?') ? fallbackUrl : '$fallbackUrl$qParam';
           response = await get(Uri.parse(fUrl), headers: headers);
        }
      }
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        final uri = Uri.file(file.path);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Status code: ${response.statusCode}, URL: $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildMessageBubble({
    required MessageMod msg,
    required String time,
    required bool isMe,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String? displayUrl = (msg.mediaUrl != null && msg.mediaUrl!.isNotEmpty)
        ? msg.mediaUrl
        : (msg.filePath != null && msg.filePath!.isNotEmpty ? msg.filePath : null);

    final fullUrl = displayUrl != null ? _getResolvedMediaUrl(displayUrl) : '';
    final isRemote = fullUrl.startsWith('http://') || fullUrl.startsWith('https://');
    final baseHost = Uri.parse(ApiConstants.baseUrl).host;
    final isBackendUrl = fullUrl.contains(baseHost) || (!fullUrl.startsWith('http') && !fullUrl.startsWith('blob:'));
    
    Map<String, String>? headers;
    if (isRemote && isBackendUrl) {
      headers = context.read<InboxRepository>().networkClient.commonHeaders();
    } else if (isRemote) {
      headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'
      };
    }

    final showText = msg.messageText.isNotEmpty && 
        !( (msg.messageText == '[Media: image]' || msg.messageText == '[Media: Image]') && (displayUrl != null && displayUrl.isNotEmpty) );

    Widget bubbleContent;

    if (msg.type == 'image') {
      bubbleContent = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    InteractiveViewer(
                      child: Image.network(
                        fullUrl,
                        headers: headers,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Image.network(
            fullUrl,
            headers: headers,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 120,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 200,
                height: 120,
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.primary),
                ),
              );
            },
          ),
        ),
      );
    } else if (msg.type == 'audio') {
      bubbleContent = InlineAudioPlayer(
        audioUrl: fullUrl,
        isMe: isMe,
      );
    } else if (msg.type == 'document') {
      final displayName = msg.messageText.isNotEmpty ? msg.messageText : 'document.pdf';
      final safeName = displayUrl != null && displayUrl.isNotEmpty 
          ? displayUrl.split('/').last.split('?').first 
          : displayName;
      final fileName = safeName.isNotEmpty ? '$safeName.pdf' : 'document.pdf';
      bubbleContent = InkWell(
        onTap: () => _downloadAndOpenMedia(fullUrl, fileName),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: isMe ? Colors.white : AppColor.primary,
              size: 32,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName.length > 20 ? '${displayName.substring(0, 17)}...' : displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black),
                  ),
                ),
                Text(
                  "Tap to open/download",
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      final mapUrl = _extractMapUrl(msg.messageText);
      if (mapUrl != null) {
        bubbleContent = SelectableText(
          mapUrl,
          onTap: () async {
            final uri = Uri.parse(mapUrl);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          style: TextStyle(
            color: isMe ? Colors.white : (isDark ? Colors.blue[300] : Colors.blue[800]),
            decoration: TextDecoration.underline,
            fontSize: 13,
          ),
        );
      } else {
        bubbleContent = Text(
          msg.messageText,
          style: TextStyle(
            color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black),
          ),
        );
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColor.primary
                  : (isDark ? theme.colorScheme.surface : const Color(0xffF3F4F6)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                bubbleContent,
                if (msg.type != 'text' && showText) ...[
                  const SizedBox(height: 8),
                  Text(
                    msg.messageText,
                    style: TextStyle(
                      color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            time,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _AnimatingHelpMeButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const _AnimatingHelpMeButton({Key? key, this.onPressed}) : super(key: key);

  @override
  State<_AnimatingHelpMeButton> createState() => _AnimatingHelpMeButtonState();
}

class _AnimatingHelpMeButtonState extends State<_AnimatingHelpMeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
          label: const Text(
            'Help me',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: const Size(110, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}