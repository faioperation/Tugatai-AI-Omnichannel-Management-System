import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Inbox/data/models/inbox_models.dart';
import 'package:roberto/features/Inbox/data/repositories/inbox_repository.dart';
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

  List<ConversationMod> _conversations = [];
  bool _conversationsLoading = false;
  String _selectedPlatform = 'all'; // 'all', 'messenger', 'instagram', 'whatsapp'
  ConversationMod? _selectedConversation;
  
  List<MessageMod> _messages = [];
  bool _messagesLoading = false;
  Timer? _messagePollTimer;
  bool _isAiOn = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchConversations();
    });
  }

  @override
  void dispose() {
    _messagePollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchConversations() async {
    if (!mounted) return;
    setState(() {
      _conversationsLoading = true;
    });

    try {
      final inboxRepo = context.read<InboxRepository>();
      final res = await inboxRepo.getConversations('all');

      if (res['success'] == true && mounted) {
        setState(() {
          _conversations = res['conversations'] as List<ConversationMod>;
          _conversationsLoading = false;
          
          if (_selectedConversation != null) {
            final match = _conversations.where((c) => c.id == _selectedConversation!.id);
            if (match.isNotEmpty) {
              _selectedConversation = match.first;
            } else {
              _selectedConversation = null;
              _messages.clear();
              _messagePollTimer?.cancel();
            }
          }
        });
      } else if (mounted) {
        setState(() {
          _conversationsLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to load conversations'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _conversationsLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading conversations: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fetchChatbotStatus(String conversationId) async {
    try {
      final inboxRepo = context.read<InboxRepository>();
      final res = await inboxRepo.getChatbotStatus(conversationId);
      if (res['success'] == true && mounted) {
        final data = res['data'];
        if (data != null && data['data'] != null) {
          final aiReply = data['data']['aiReply'];
          if (aiReply is bool) {
            setState(() {
              _isAiOn = aiReply;
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleChatbot(bool val) async {
    if (_selectedConversation == null) return;
    final conv = _selectedConversation!;

    setState(() {
      _isAiOn = val;
    });

    final action = val ? 'resume' : 'pause';
    try {
      final inboxRepo = context.read<InboxRepository>();
      final res = await inboxRepo.toggleChatbotStatus(conv.id, action);
      if (res['success'] == true) {
        _fetchConversations();
      } else {
        setState(() {
          _isAiOn = !val;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Failed to update chatbot status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isAiOn = !val;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating chatbot status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchMessages(ConversationMod conversation, {bool showLoading = true}) async {
    _messagePollTimer?.cancel();
    
    if (showLoading && mounted) {
      setState(() {
        _messagesLoading = true;
      });
    }

    try {
      final inboxRepo = context.read<InboxRepository>();
      final res = await inboxRepo.getMessages(conversation.platform, conversation.id);

      if (res['success'] == true && mounted) {
        setState(() {
          _messages = res['messages'] as List<MessageMod>;
          _messagesLoading = false;
        });
        _startMessagePolling(conversation);
      } else if (mounted) {
        setState(() {
          _messagesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messagesLoading = false;
        });
      }
    }
  }

  void _startMessagePolling(ConversationMod conversation) {
    _messagePollTimer?.cancel();
    _messagePollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_selectedConversation?.id == conversation.id && mounted) {
        _fetchMessages(conversation, showLoading: false);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendTextMessage(String text) async {
    if (_selectedConversation == null) return;
    final conv = _selectedConversation!;

    final tempMsg = MessageMod(
      id: DateTime.now().toString(),
      conversationId: conv.id,
      senderType: 'agent',
      senderId: 'me',
      type: 'text',
      messageText: text,
      aiReply: false,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    
    setState(() {
      _messages.add(tempMsg);
    });

    try {
      final inboxRepo = context.read<InboxRepository>();
      final res = await inboxRepo.sendTextMessage(conv.platform, conv.customerId, text);

      if (res['success'] == true) {
        _fetchConversations();
        _fetchMessages(conv, showLoading: false);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Failed to send message'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _sendImageMessage(String imagePath, List<int> bytes, String filename) async {
    if (_selectedConversation == null) return;
    final conv = _selectedConversation!;

    final tempMsg = MessageMod(
      id: DateTime.now().toString(),
      conversationId: conv.id,
      senderType: 'agent',
      senderId: 'me',
      type: 'image',
      messageText: '',
      filePath: imagePath,
      aiReply: false,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    setState(() {
      _messages.add(tempMsg);
    });

    try {
      final inboxRepo = context.read<InboxRepository>();
      final res = await inboxRepo.sendImageMessage(
        conv.platform,
        conv.customerId,
        imagePath,
        fileBytes: bytes,
        fileName: filename,
      );

      if (res['success'] == true) {
        _fetchConversations();
        _fetchMessages(conv, showLoading: false);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Failed to send image'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
                            Expanded(flex: 3, child: ChatList(
                              conversations: _conversations,
                              selectedConversation: _selectedConversation,
                              selectedPlatform: _selectedPlatform,
                              isLoading: _conversationsLoading,
                              onPlatformChanged: (platform) {
                                setState(() {
                                  _selectedPlatform = platform;
                                  if (_selectedConversation != null &&
                                      platform != 'all' &&
                                      _selectedConversation!.platform.toLowerCase() != platform.toLowerCase()) {
                                    _selectedConversation = null;
                                    _messages.clear();
                                    _messagePollTimer?.cancel();
                                  }
                                });
                              },
                              onConversationSelected: (conv) {
                                setState(() {
                                  _selectedConversation = conv;
                                  _isAiOn = conv.aiReply;
                                });
                                _fetchMessages(conv);
                                _fetchChatbotStatus(conv.id);
                              },
                            )),
                            const VerticalDivider(width: 1, thickness: 1),
                            Expanded(flex: 5, child: ChatView(
                              conversation: _selectedConversation,
                              messages: _messages,
                              isLoading: _messagesLoading,
                              onBack: null,
                              onSendMessage: _sendTextMessage,
                              onSendImage: _sendImageMessage,
                              isAiOn: _isAiOn,
                              onToggleAi: _toggleChatbot,
                            )),
                            const VerticalDivider(width: 1, thickness: 1),
                            Expanded(flex: 3, child: ChatDetails(
                              conversation: _selectedConversation,
                            )),
                          ],
                        )
                      : isTablet
                          ? Row(
                              children: [
                                Expanded(flex: 3, child: ChatList(
                                  conversations: _conversations,
                                  selectedConversation: _selectedConversation,
                                  selectedPlatform: _selectedPlatform,
                                  isLoading: _conversationsLoading,
                                  onPlatformChanged: (platform) {
                                    setState(() {
                                      _selectedPlatform = platform;
                                      if (_selectedConversation != null &&
                                          platform != 'all' &&
                                          _selectedConversation!.platform.toLowerCase() != platform.toLowerCase()) {
                                        _selectedConversation = null;
                                        _messages.clear();
                                        _messagePollTimer?.cancel();
                                      }
                                    });
                                  },
                                  onConversationSelected: (conv) {
                                    setState(() {
                                      _selectedConversation = conv;
                                      _isAiOn = conv.aiReply;
                                    });
                                    _fetchMessages(conv);
                                    _fetchChatbotStatus(conv.id);
                                  },
                                )),
                                const VerticalDivider(width: 1, thickness: 1),
                                Expanded(flex: 5, child: ChatView(
                                  conversation: _selectedConversation,
                                  messages: _messages,
                                  isLoading: _messagesLoading,
                                  onBack: null,
                                  onSendMessage: _sendTextMessage,
                                  onSendImage: _sendImageMessage,
                                  isAiOn: _isAiOn,
                                  onToggleAi: _toggleChatbot,
                                )),
                              ],
                            )
                          : Column(
                              children: [
                                if (!_showChatViewOnMobile)
                                  Expanded(
                                    child: ChatList(
                                      conversations: _conversations,
                                      selectedConversation: _selectedConversation,
                                      selectedPlatform: _selectedPlatform,
                                      isLoading: _conversationsLoading,
                                      onPlatformChanged: (platform) {
                                        setState(() {
                                          _selectedPlatform = platform;
                                          if (_selectedConversation != null &&
                                              platform != 'all' &&
                                              _selectedConversation!.platform.toLowerCase() != platform.toLowerCase()) {
                                            _selectedConversation = null;
                                            _messages.clear();
                                            _messagePollTimer?.cancel();
                                          }
                                        });
                                      },
                                      onConversationSelected: (conv) {
                                        setState(() {
                                          _selectedConversation = conv;
                                          _showChatViewOnMobile = true;
                                          _isAiOn = conv.aiReply;
                                        });
                                        _fetchMessages(conv);
                                        _fetchChatbotStatus(conv.id);
                                      },
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: ChatView(
                                      conversation: _selectedConversation,
                                      messages: _messages,
                                      isLoading: _messagesLoading,
                                      onBack: () {
                                        setState(() {
                                          _showChatViewOnMobile = false;
                                        });
                                      },
                                      onSendMessage: _sendTextMessage,
                                      onSendImage: _sendImageMessage,
                                      isAiOn: _isAiOn,
                                      onToggleAi: _toggleChatbot,
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
