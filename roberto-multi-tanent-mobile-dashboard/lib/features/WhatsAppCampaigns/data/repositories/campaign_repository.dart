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
    required String name,
    required String branchId,
    required String message,
    required DateTime endDate,
  }) async {
    try {
      final response = await _networkClient.postRequest(
        ApiConstants.businessOwnerCampaignCreate,
        body: {
          'name': name,
          'branchId': branchId,
          'message': message,
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
    String? name,
    String? branchId,
    String? message,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (branchId != null) body['branchId'] = branchId;
      if (message != null) body['message'] = message;
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
