import 'dart:convert';

class ConversationMod {
  final String id;
  final String businessId;
  final String branchId;
  final String platform;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String lastMessage;
  final String lastMessageAt;
  final String lastMessageDirection; // 'INCOMING' | 'OUTGOING' | ''
  final int unreadCount;
  final bool aiReply;
  final bool seen;
  final ChatSummaryMod? chatSummary;

  ConversationMod({
    required this.id,
    required this.businessId,
    required this.branchId,
    required this.platform,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.lastMessage,
    required this.lastMessageAt,
    this.lastMessageDirection = '',
    required this.unreadCount,
    required this.aiReply,
    this.seen = false,
    this.chatSummary,
  });

  factory ConversationMod.fromJson(Map<String, dynamic> json) {
    // lastMessage can be a String or an object like {"messageText":"...","direction":"INCOMING"}
    String parsedLastMessage = '';
    String parsedLastMessageDirection = '';
    final rawLast = json['lastMessage'];
    if (rawLast is String) {
      parsedLastMessage = rawLast;
    } else if (rawLast is Map<String, dynamic>) {
      parsedLastMessage = (rawLast['messageText']?.toString().isNotEmpty == true
              ? rawLast['messageText'].toString()
              : null) ??
          (rawLast['text']?.toString().isNotEmpty == true
              ? rawLast['text'].toString()
              : null) ??
          (rawLast['content']?.toString().isNotEmpty == true
              ? rawLast['content'].toString()
              : null) ??
          '';
      parsedLastMessageDirection = rawLast['direction']?.toString().toUpperCase() ?? '';
      // If messageText is empty but type is not text, show a media placeholder
      if (parsedLastMessage.isEmpty) {
        final msgType = rawLast['type']?.toString().toLowerCase() ?? '';
        if (msgType == 'image') {
          parsedLastMessage = '📷 Photo';
        } else if (msgType == 'audio') {
          parsedLastMessage = '🎵 Voice message';
        } else if (msgType == 'video') {
          parsedLastMessage = '🎥 Video';
        } else if (msgType == 'document') {
          parsedLastMessage = '📄 Document';
        } else {
          parsedLastMessage = '💬 Message';
        }
      }
    } else if (rawLast == null) {
      parsedLastMessage = '';
    }

    // Fallback: try lastMessageText field directly
    if (parsedLastMessage.isEmpty) {
      parsedLastMessage = json['lastMessageText']?.toString() ?? '';
    }

    // Fallback: try lastMessage as nested text fields
    if (parsedLastMessage.isEmpty) {
      parsedLastMessage = json['lastMessageContent']?.toString() ?? '';
    }

    // Direction from top-level field
    if (parsedLastMessageDirection.isEmpty) {
      parsedLastMessageDirection = json['lastMessageDirection']?.toString().toUpperCase() ?? '';
    }

    return ConversationMod(
      id: json['id'] ?? '',
      businessId: json['businessId'] ?? '',
      branchId: json['branchId'] ?? '',
      platform: json['platform'] ?? 'messenger',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] != null && json['customerName'].toString().isNotEmpty
          ? json['customerName']
          : 'Social Customer',
      customerPhone: json['customerPhone'],
      lastMessage: parsedLastMessage,
      lastMessageAt: json['lastMessageAt'] ?? '',
      lastMessageDirection: parsedLastMessageDirection,
      unreadCount: json['unreadCount'] ?? 0,
      aiReply: json['aiReply'] ?? false,
      seen: json['seen'] ?? false,
      chatSummary: json['chatSummary'] != null ? ChatSummaryMod.fromJson(json['chatSummary']) : null,
    );
  }
}

class ChatSummaryMod {
  final String id;
  final String conversationId;
  final String? items;
  final String? pickupArea;
  final String? destination;
  final String? weight;
  final String? pickupDateTime;
  final String currentStatus;
  final String? recentSummary;
  final String? summary;
  final List<String> keyPoints;
  final String? intent;
  final String? confidence;
  final String? reason;
  final BookingInfoMod? bookingInfo;

  ChatSummaryMod({
    required this.id,
    required this.conversationId,
    this.items,
    this.pickupArea,
    this.destination,
    this.weight,
    this.pickupDateTime,
    required this.currentStatus,
    this.recentSummary,
    this.summary,
    required this.keyPoints,
    this.intent,
    this.confidence,
    this.reason,
    this.bookingInfo,
  });

  factory ChatSummaryMod.fromJson(Map<String, dynamic> json) {
    var keys = json['keyPoints'];
    List<String> parsedKeys = [];
    if (keys is List) {
      parsedKeys = keys.map((e) => e.toString()).toList();
    }
    return ChatSummaryMod(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      items: json['items'],
      pickupArea: json['pickupArea'],
      destination: json['destination'],
      weight: json['weight'],
      pickupDateTime: json['pickupDateTime'],
      currentStatus: json['currentStatus'] ?? 'Inquiry',
      recentSummary: json['recentSummary'],
      summary: json['summary'],
      keyPoints: parsedKeys,
      intent: json['intent'],
      confidence: json['confidence'],
      reason: json['reason'],
      bookingInfo: json['bookingInfo'] != null ? BookingInfoMod.fromJson(json['bookingInfo']) : null,
    );
  }
}

class BookingInfoMod {
  final double? price;
  final bool booked;
  final String? reference;

  BookingInfoMod({
    this.price,
    required this.booked,
    this.reference,
  });

  factory BookingInfoMod.fromJson(Map<String, dynamic> json) {
    return BookingInfoMod(
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      booked: json['booked'] ?? false,
      reference: json['reference'],
    );
  }
}

class MessageMod {
  final String id;
  final String conversationId;
  final String senderType; // "customer" or "agent"
  final String senderId;
  final String type; // "text" or "image"
  final String messageText;
  final String? mediaUrl;
  final String? filePath;
  final bool aiReply;
  final String createdAt;

  MessageMod({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.senderId,
    required this.type,
    required this.messageText,
    this.mediaUrl,
    this.filePath,
    required this.aiReply,
    required this.createdAt,
  });

  bool get isMe => senderType == 'agent';

  factory MessageMod.fromJson(Map<String, dynamic> json) {
    String senderType = json['senderType'] ?? '';
    if (senderType.isEmpty) {
      final direction = json['direction']?.toString().toUpperCase();
      if (direction == 'OUTGOING') {
        senderType = 'agent';
      } else if (direction == 'INCOMING') {
        senderType = 'customer';
      } else {
        if (json['rawPayload'] == null) {
          senderType = 'agent';
        } else {
          senderType = 'customer';
        }
      }
    } else {
      final lowerType = senderType.toLowerCase();
      if (lowerType == 'business' || lowerType == 'agent' || lowerType == 'me') {
        senderType = 'agent';
      } else {
        senderType = 'customer';
      }
    }

    String messageText = json['messageText'] ?? json['text'] ?? '';

    String? mediaUrl = json['mediaUrl'];
    String type = json['type'] ?? 'text';
    
    if (json['rawPayload'] != null) {
      try {
        var rawPayload = json['rawPayload'];
        while (rawPayload is String) {
          // ignore: prefer_typing_uninitialized_variables
          rawPayload = jsonDecode(rawPayload);
        }
        if (rawPayload is Map && rawPayload['message'] != null && rawPayload['message']['attachments'] != null) {
          final attachments = rawPayload['message']['attachments'] as List;
          if (attachments.isNotEmpty) {
            final firstAttachment = attachments.first;
            
            // Extract URL if mediaUrl is missing
            if ((mediaUrl == null || mediaUrl.isEmpty) && firstAttachment['payload'] != null && firstAttachment['payload']['url'] != null) {
              mediaUrl = firstAttachment['payload']['url'];
            }
            
            // Update type based on attachment type
            if (firstAttachment['type'] != null) {
              final attType = firstAttachment['type'].toString().toLowerCase();
              if (attType == 'image' || attType == 'audio' || attType == 'video') {
                type = attType;
              } else if (attType == 'file' || attType == 'document') {
                type = 'document';
              }
            }
          }
        }
      } catch (e) {
        // Ignore parsing errors for rawPayload
      }
    }

    // Fallback if type is still 'media' (from Instagram payload)
    if (type == 'media') {
      type = 'image'; // default to image if we couldn't parse a better type
    }

    return MessageMod(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderType: senderType,
      senderId: json['senderId'] ?? '',
      type: type,
      messageText: messageText,
      mediaUrl: mediaUrl,
      filePath: json['filePath'],
      aiReply: json['aiReply'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
