import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/Inbox/data/models/inbox_models.dart';

class InboxRepository {
  final NetworkClient networkClient;

  InboxRepository({required this.networkClient});

  Future<Map<String, dynamic>> getConversations(String platform) async {
    String url = ApiConstants.allConversations;
    if (platform == 'messenger') {
      url = ApiConstants.messengerConversations;
    } else if (platform == 'instagram') {
      url = ApiConstants.instagramConversations;
    } else if (platform == 'whatsapp') {
      url = ApiConstants.whatsappConversations;
    }

    final response = await networkClient.getRequest(url);

    if (response.isSuccess) {
      final List<ConversationMod> list = [];
      final data = response.responseData;
      if (data != null && data['data'] is List) {
        for (var item in data['data']) {
          list.add(ConversationMod.fromJson(item));
        }
      }
      return {
        'success': true,
        'conversations': list,
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to fetch conversations',
      };
    }
  }

  Future<Map<String, dynamic>> getMessages(String platform, String conversationId) async {
    String url;
    if (platform == 'whatsapp') {
      url = '${ApiConstants.whatsappMessages}/$conversationId/messages';
    } else if (platform == 'instagram') {
      url = '${ApiConstants.instagramMessages}/$conversationId';
    } else {
      url = '${ApiConstants.messengerMessages}/$conversationId';
    }

    final response = await networkClient.getRequest(url);

    if (response.isSuccess) {
      final List<MessageMod> list = [];
      final data = response.responseData;
      if (data != null && data['data'] is List) {
        for (var item in data['data']) {
          list.add(MessageMod.fromJson(item));
        }
      }
      return {
        'success': true,
        'messages': list,
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to fetch messages',
      };
    }
  }

  Future<Map<String, dynamic>> sendTextMessage(String platform, String recipientId, String message) async {
    String url = ApiConstants.messengerSendText;
    if (platform == 'whatsapp') {
      url = ApiConstants.whatsappSendText;
    } else if (platform == 'instagram') {
      url = ApiConstants.instagramSendText;
    }

    final response = await networkClient.postRequest(
      url,
      body: {
        'recipientId': recipientId,
        'message': message,
      },
    );

    if (response.isSuccess) {
      return {
        'success': true,
        'data': response.responseData,
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to send message',
      };
    }
  }

  Future<Map<String, dynamic>> sendImageMessage(
    String platform,
    String recipientId,
    String imagePath, {
    List<int>? fileBytes,
    String? fileName,
  }) async {
    String url = ApiConstants.messengerSendMedia;
    if (platform == 'whatsapp') {
      url = ApiConstants.whatsappSendMedia;
    } else if (platform == 'instagram') {
      url = ApiConstants.instagramSendMedia;
    }

    final response = await networkClient.postMultipartRequest(
      url,
      body: {
        'recipientId': recipientId,
        'type': 'image',
      },
      files: fileBytes == null ? {'file': imagePath} : null,
      fileBytes: fileBytes != null ? {'file': fileBytes} : null,
      fileNames: fileName != null ? {'file': fileName} : null,
    );

    if (response.isSuccess) {
      return {
        'success': true,
        'data': response.responseData,
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to send image',
      };
    }
  }

  Future<Map<String, dynamic>> getChatbotStatus(String conversationId) async {
    final url = '${ApiConstants.conversationOff}/$conversationId';
    final response = await networkClient.getRequest(url);

    if (response.isSuccess) {
      return {
        'success': true,
        'data': response.responseData,
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to retrieve chatbot status',
      };
    }
  }

  Future<Map<String, dynamic>> toggleChatbotStatus(String conversationId, String action) async {
    final url = ApiConstants.conversationOffHandoff;
    final response = await networkClient.postRequest(
      url,
      body: {
        'conversationId': conversationId,
        'action': action,
      },
    );

    if (response.isSuccess) {
      return {
        'success': true,
        'data': response.responseData,
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to update chatbot status',
      };
    }
  }
}
