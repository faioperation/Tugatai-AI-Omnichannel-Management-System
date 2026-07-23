import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/WhatsAppCampaigns/data/models/campaign_model.dart';

class CampaignRepository {
  final NetworkClient _networkClient;
  final bool isBranchManager;

  CampaignRepository({required NetworkClient networkClient, this.isBranchManager = false})
      : _networkClient = networkClient;

  Future<List<CampaignModel>> getCampaigns({String? branchId}) async {
    try {
      final baseEndpoint = isBranchManager
          ? '${ApiConstants.baseUrl}/branch-manager/campaigns/all'
          : ApiConstants.businessOwnerCampaigns;
      final url = branchId != null ? '$baseEndpoint?branchId=$branchId' : baseEndpoint;
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
    String? country,
    String? productType,
  }) async {
    try {
      final baseEndpoint = isBranchManager
          ? '${ApiConstants.baseUrl}/branch-manager/campaigns/create'
          : ApiConstants.businessOwnerCampaignCreate;
      final body = {
        'title': title,
        'message': message,
        'branchId': branchId,
        'selectedPeople': selectedPeople,
        'scheduledTime': scheduledTime.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (country != null && country.isNotEmpty) 'country': country,
        if (productType != null && productType.isNotEmpty) 'productType': productType,
      };
      final response = await _networkClient.postRequest(
        baseEndpoint,
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

  Future<CampaignModel> updateCampaign({
    required String id,
    String? title,
    String? message,
    String? branchId,
    List<String>? selectedPeople,
    DateTime? scheduledTime,
    DateTime? endDate,
    String? country,
    String? productType,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (message != null) body['message'] = message;
      if (branchId != null) body['branchId'] = branchId;
      if (selectedPeople != null) body['selectedPeople'] = selectedPeople;
      if (scheduledTime != null) body['scheduledTime'] = scheduledTime.toIso8601String();
      if (endDate != null) body['endDate'] = endDate.toIso8601String();
      if (country != null && country.isNotEmpty) body['country'] = country;
      if (productType != null && productType.isNotEmpty) body['productType'] = productType;

      final baseEndpoint = isBranchManager
          ? '${ApiConstants.baseUrl}/branch-manager/campaigns'
          : ApiConstants.businessOwnerCampaignUpdate;
      final response = await _networkClient.patchRequest(
        '$baseEndpoint/$id',
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
      final baseEndpoint = isBranchManager
          ? '${ApiConstants.baseUrl}/branch-manager/campaigns'
          : ApiConstants.businessOwnerCampaignDelete;
      final response = await _networkClient.deleteRequest(
        '$baseEndpoint/$id',
      );
      if (!response.isSuccess) {
        throw Exception(response.errorMassage);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getCampaignCountries(String branchId, {bool? isBranchManagerOverride}) async {
    try {
      final isManager = isBranchManagerOverride ?? isBranchManager;
      final endpoint = isManager
          ? ApiConstants.branchManagerBookingCountries
          : ApiConstants.businessOwnerBookingCountries;
      final url = '$endpoint?branchId=$branchId';
      final response = await _networkClient.getRequest(url);
      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {'success': false, 'message': response.errorMassage ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCampaignProductTypes(String branchId, {bool? isBranchManagerOverride}) async {
    try {
      final isManager = isBranchManagerOverride ?? isBranchManager;
      final endpoint = isManager
          ? ApiConstants.branchManagerCrmProductTypes
          : ApiConstants.businessOwnerCrmProductTypes;
      // Branch manager endpoint does not require branchId
      final url = isManager ? endpoint : '$endpoint?branchId=$branchId';
      final response = await _networkClient.getRequest(url);
      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {'success': false, 'message': response.errorMassage ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
