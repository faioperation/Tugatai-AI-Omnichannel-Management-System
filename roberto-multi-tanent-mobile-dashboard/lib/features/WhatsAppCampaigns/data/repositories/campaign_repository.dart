import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/WhatsAppCampaigns/data/models/campaign_model.dart';

class CampaignRepository {
  final NetworkClient _networkClient;

  CampaignRepository({required NetworkClient networkClient})
      : _networkClient = networkClient;

  Future<List<CampaignModel>> getCampaigns({String? branchId}) async {
    try {
      final url = branchId != null ? '${ApiConstants.businessOwnerCampaigns}?branchId=$branchId' : ApiConstants.businessOwnerCampaigns;
      final response = await _networkClient.getRequest(url);
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
    required String message,
    required String branchId,
    required List<String> selectedPeople,
    required DateTime scheduledTime,
    required DateTime endDate,
  }) async {
    try {
      final response = await _networkClient.postRequest(
        ApiConstants.businessOwnerCampaignCreate,
        body: {
          'title': title,
          'message': message,
          'branchId': branchId,
          'selectedPeople': selectedPeople,
          'scheduledTime': scheduledTime.toIso8601String(),
          'endDate': endDate.toIso8601String(),
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
    String? message,
    String? branchId,
    List<String>? selectedPeople,
    DateTime? scheduledTime,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (message != null) body['message'] = message;
      if (branchId != null) body['branchId'] = branchId;
      if (selectedPeople != null) body['selectedPeople'] = selectedPeople;
      if (scheduledTime != null) body['scheduledTime'] = scheduledTime.toIso8601String();
      if (endDate != null) body['endDate'] = endDate.toIso8601String();

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
