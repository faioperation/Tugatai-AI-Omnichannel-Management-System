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
  final String? branchId;
  final String? initialCustomerPhone;
  final String? initialCustomerName;
  final String? initialConversationId;
  const InboxScreen({super.key, this.isSystemOwner = false, this.branchId, this.initialCustomerPhone, this.initialCustomerName, this.initialConversationId});

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
  Timer? _conversationsPollTimer;
  bool _isAiOn = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchConversations();
      _startConversationsPolling();
    });
  }

  @override
  void dispose() {
    _conversationsPollTimer?.cancel();
    _messagePollTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId) {
      _fetchConversations();
    }
  }

  Future<void> _fetchConversations() async {
    if (!mounted) return;
    setState(() {
      _conversationsLoading = true;
    });

    try {
      final inboxRepo = context.read<InboxRepository>();
      final res = await inboxRepo.getConversations('all', branchId: widget.branchId);

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
          } else if (widget.initialConversationId != null) {
            final match = _conversations.where((c) => c.id == widget.initialConversationId);
            if (match.isNotEmpty) {
              _openConversation(match.first);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Not found this conversation, I think it's from another platform or it's a voice call"),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else if (widget.initialCustomerPhone != null || widget.initialCustomerName != null) {
            final match = _conversations.where((c) {
              if (widget.initialCustomerPhone != null && c.customerPhone == widget.initialCustomerPhone) {
                return true;
              }
              if (widget.initialCustomerName != null) {
                final cName = c.customerName.toLowerCase();
                final iName = widget.initialCustomerName!.toLowerCase();
                if (cName.contains(iName) || iName.contains(cName)) {
                  return true;
                }
              }
              return false;
            });
            if (match.isNotEmpty) {
              _openConversation(match.first);
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

  Future<void> _fetchConversationsSilent() async {
    try {
      final inboxRepo = context.read<InboxRepository>();
      final res = await inboxRepo.getConversations('all', branchId: widget.branchId);

      if (res['success'] == true && mounted) {
        setState(() {
          _conversations = res['conversations'] as List<ConversationMod>;
          
          if (_selectedConversation != null) {
            final match = _conversations.where((c) => c.id == _selectedConversation!.id);
            if (match.isNotEmpty) {
              _selectedConversation = match.first;
            }
          }
        });
      }
    } catch (_) {}
  }

  void _openConversation(ConversationMod conv) {
    if (mounted) {
      setState(() {
        _selectedConversation = conv;
        _showChatViewOnMobile = true;
        _isAiOn = conv.aiReply;
      });
    }
    _fetchMessages(conv);
    _fetchChatbotStatus(conv.id);
    if (!conv.seen) {
      _markAsSeen(conv.id);
    }
  }

  Future<void> _markAsSeen(String conversationId) async {
    try {
      final inboxRepo = context.read<InboxRepository>();
      final res = await inboxRepo.markConversationAsSeen(conversationId);
      if (res['success'] == true && mounted) {
        setState(() {
          final idx = _conversations.indexWhere((c) => c.id == conversationId);
          if (idx != -1) {
             final old = _conversations[idx];
             _conversations[idx] = ConversationMod(
                id: old.id,
                businessId: old.businessId,
                branchId: old.branchId,
                platform: old.platform,
                customerId: old.customerId,
                customerName: old.customerName,
                customerPhone: old.customerPhone,
                lastMessage: old.lastMessage,
                lastMessageAt: old.lastMessageAt,
                unreadCount: old.unreadCount,
                aiReply: old.aiReply,
                seen: true,
                chatSummary: old.chatSummary,
             );
             if (_selectedConversation?.id == conversationId) {
               _selectedConversation = _conversations[idx];
             }
          }
        });
      }
    } catch (_) {}
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
        final newMsgs = res['messages'] as List<MessageMod>;
        
        bool hasNewMessage = false;
        if (newMsgs.length != _messages.length) {
          hasNewMessage = true;
        } else if (newMsgs.isNotEmpty && _messages.isNotEmpty) {
          if (newMsgs.last.id != _messages.last.id || newMsgs.last.messageText != _messages.last.messageText) {
            hasNewMessage = true;
          }
        }

        setState(() {
          _messages = newMsgs;
          _messagesLoading = false;
        });

        if (hasNewMessage) {
          _fetchConversationsSilent();
        }

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

  void _startConversationsPolling() {
    _conversationsPollTimer?.cancel();
    _conversationsPollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchConversationsSilent();
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
      final res = await inboxRepo.sendTextMessage(conv.platform, conv.customerId, text, conversationId: conv.id);

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
        conversationId: conv.id,
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
              if (!isMobile) ...[
                Text(
                  "Inbox",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Manage all your customer conversations in one place",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Chat UI Container
              Container(
                height: isMobile 
                    ? MediaQuery.of(context).size.height - 170 
                    : (MediaQuery.of(context).size.height > 600 ? MediaQuery.of(context).size.height - 220 : 600),
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
                                _openConversation(conv);
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
                                    _openConversation(conv);
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
                                        _openConversation(conv);
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
