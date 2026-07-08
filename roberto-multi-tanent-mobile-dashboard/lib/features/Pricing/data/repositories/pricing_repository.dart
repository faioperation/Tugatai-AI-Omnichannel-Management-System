import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';

class PricingRepository {
  final NetworkClient networkClient;

  PricingRepository({required this.networkClient});

  Future<Map<String, dynamic>> getPricingRules({
    int page = 1,
    int limit = 10,
    bool isBranchManager = false,
    String? branchId,
  }) async {
    // Assuming standard Business Owner endpoint for future implementation if needed
    final baseUrl = isBranchManager ? ApiConstants.branchManagerPricingAll : '${ApiConstants.baseUrl}/business-owner/pricings/all';
    final url = branchId != null ? '$baseUrl?page=$page&limit=$limit&branchId=$branchId' : '$baseUrl?page=$page&limit=$limit';

    final response = await networkClient.getRequest(url);

    if (response.isSuccess) {
      return {
        'success': true,
        'data': response.responseData,
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to fetch pricing rules',
      };
    }
  }

  Future<Map<String, dynamic>> createPricingRule({
    required String ruleName,
    required String type,
    required Map<String, dynamic> configuration,
    required bool status,
    String? branchId,
    bool isBranchManager = false,
  }) async {
    final body = {
      "ruleName": ruleName,
      "type": type,
      "configuration": configuration,
      "status": status,
    };
    if (branchId != null) {
      body['branchId'] = branchId;
    }

    final baseUrl = isBranchManager ? ApiConstants.branchManagerPricingCreate : '${ApiConstants.baseUrl}/business-owner/pricings/create';
    final response = await networkClient.postRequest(
      baseUrl,
      body: body,
    );

    if (response.isSuccess) {
      return {
        'success': true,
        'data': response.responseData,
        'message': 'Created successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to create pricing rule',
      };
    }
  }

  Future<Map<String, dynamic>> updatePricingRule({
    required String id,
    String? ruleName,
    String? type,
    Map<String, dynamic>? configuration,
    bool? status,
    String? branchId,
    bool isBranchManager = false,
  }) async {
    final baseUrl = isBranchManager ? ApiConstants.branchManagerPricingSingle : '${ApiConstants.baseUrl}/business-owner/pricings';
    final url = '$baseUrl/$id';
    
    final body = <String, dynamic>{};
    if (ruleName != null) body['ruleName'] = ruleName;
    if (type != null) body['type'] = type;
    if (configuration != null) body['configuration'] = configuration;
    if (status != null) body['status'] = status;
    if (branchId != null) body['branchId'] = branchId;

    final response = await networkClient.patchRequest(
      url,
      body: body,
    );

    if (response.isSuccess) {
      return {
        'success': true,
        'data': response.responseData,
        'message': 'Updated successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to update pricing rule',
      };
    }
  }

  Future<Map<String, dynamic>> deletePricingRule({required String id, bool isBranchManager = false}) async {
    final baseUrl = isBranchManager ? ApiConstants.branchManagerPricingSingle : '${ApiConstants.baseUrl}/business-owner/pricings';
    final url = '$baseUrl/$id';
    final response = await networkClient.deleteRequest(url);

    if (response.isSuccess) {
      return {
        'success': true,
        'message': 'Deleted successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to delete pricing rule',
      };
    }
  }

  Future<Map<String, dynamic>> calculatePrice({
    required String pricingId,
    required double weight,
    required double distance,
    required String serviceType,
    required String selectedExtras,
    required int quantity,
  }) async {
    final queryParams = [
      'pricingId=$pricingId',
      'weight=$weight',
      'distance=$distance',
      'serviceType=$serviceType',
      'selectedExtras=$selectedExtras',
      'quantity=$quantity',
    ].join('&');

    final url = '${ApiConstants.baseUrl}/pricing-calculator/calculate?$queryParams';
    final response = await networkClient.getRequest(url);

    if (response.isSuccess) {
      return {
        'success': true,
        'data': response.responseData,
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage ?? 'Failed to calculate price',
      };
    }
  }
}
