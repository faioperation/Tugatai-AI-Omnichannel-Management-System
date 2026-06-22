import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/WhatsAppCampaigns/data/models/campaign_model.dart';

class CampaignRepository {
  final NetworkClient _networkClient;

  CampaignRepository({required NetworkClient networkClient})
      : _networkClient = networkClient;

  Future<List<CampaignModel>> getCampaigns() async {
    try {
      final response = await _networkClient.getRequest(ApiConstants.businessOwnerCampaigns);
      if (response.isSuccess) {
        final List<dynamic> data = response.responseData['data'] ?? [];
        return data.map((json) => CampaignModel.fromJson(json)).toList();
      } else {
        throw Exception(response.errorMassage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<CampaignModel> createCampaign({
    required String title,
    required String audience,
    required String inboxId,
    required List<String> selectedPeople,
  }) async {
    try {
      final response = await _networkClient.postRequest(
        ApiConstants.businessOwnerCampaignCreate,
        body: {
          'title': title,
          'audience': audience,
          'inboxId': inboxId,
          'selectedPeople': selectedPeople,
        },
      );
      if (response.isSuccess) {
        return CampaignModel.fromJson(response.responseData['data']);
      } else {
        throw Exception(response.errorMassage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<CampaignModel> updateCampaign({
    required String id,
    String? title,
    String? audience,
    String? inboxId,
    List<String>? selectedPeople,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (audience != null) body['audience'] = audience;
      if (inboxId != null) body['inboxId'] = inboxId;
      if (selectedPeople != null) body['selectedPeople'] = selectedPeople;

      final response = await _networkClient.patchRequest(
        '${ApiConstants.businessOwnerCampaignUpdate}/$id',
        body: body,
      );
      if (response.isSuccess) {
        return CampaignModel.fromJson(response.responseData['data']);
      } else {
        throw Exception(response.errorMassage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteCampaign(String id) async {
    try {
      final response = await _networkClient.deleteRequest(
        '${ApiConstants.businessOwnerCampaignDelete}/$id',
      );
      if (!response.isSuccess) {
        throw Exception(response.errorMassage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
