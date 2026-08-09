import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/features/WebChat/data/models/web_chat_model.dart';

class WebChatRepository {
  final NetworkClient networkClient;

  WebChatRepository({required this.networkClient});

  Future<List<WebChatWebhook>> getAllWebhooks() async {
    try {
      final response = await networkClient.getRequest('${ApiConstants.baseUrl}/v1/public/webhook/all');
      if (response.isSuccess) {
        final List<dynamic> data = response.responseData?['data'] ?? [];
        return data.map((json) => WebChatWebhook.fromJson(json)).toList();
      }
      throw Exception(response.errorMassage ?? 'Failed to fetch webhooks');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> generateWebhook({
    required String businessId,
    required String branchId,
  }) async {
    try {
      final response = await networkClient.postRequest(
        '${ApiConstants.baseUrl}/v1/public/webhook/generate',
        body: {
          'businessId': businessId,
          'branchId': branchId,
        },
      );
      if (!response.isSuccess) {
        throw Exception(response.errorMassage ?? 'Failed to generate webhook');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
