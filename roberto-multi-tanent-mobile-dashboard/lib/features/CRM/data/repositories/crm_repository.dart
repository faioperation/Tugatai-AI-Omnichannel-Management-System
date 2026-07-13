import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/CRM/data/models/crm_lead_model.dart';
import 'package:roberto/core/services/local_storage_service.dart';

class CrmRepository {
  final NetworkClient networkClient;

  CrmRepository({required this.networkClient});

  Future<Map<String, dynamic>> getLeads({
    required String branchId,
    int page = 1,
    int limit = 10,
    String searchParam = '',
    bool isBranchManager = false,
    String country = '',
    String productType = '',
  }) async {
    final baseUrl = isBranchManager ? ApiConstants.branchManagerCrmLeads : ApiConstants.businessOwnerCrmLeads;
    var url = '$baseUrl?branchId=$branchId&page=$page&limit=$limit&searchParam=$searchParam';
    if (country.isNotEmpty && country != 'All countries') {
      url += '&country=$country';
    }
    if (productType.isNotEmpty && productType != 'All types') {
      url += '&productType=$productType';
    }
    
    final response = await networkClient.getRequest(url);

    if (response.isSuccess) {
      final List<dynamic> dataList = response.responseData?['data'] ?? [];
      final List<CrmLeadModel> leads = dataList.map((json) => CrmLeadModel.fromJson(json)).toList();
      
      final meta = response.responseData?['meta'];
      
      return {
        'leads': leads,
        'meta': meta,
        'success': true,
      };
    } else {
      return {
        'leads': <CrmLeadModel>[],
        'meta': null,
        'success': false,
        'message': response.errorMassage,
      };
    }
  }

  Future<Map<String, dynamic>> createLead({
    required String branchId,
    required String name,
    required String email,
    required String phone,
    required String source,
    String country = '',
    required String address,
    required String note,
    required String status,
    Map<String, dynamic>? metadata,
    bool isBranchManager = false,
  }) async {
    final body = {
      "branchId": branchId,
      "name": name,
      "email": email,
      "phone": phone,
      "source": source,
      if (country.isNotEmpty) "country": country,
      "address": address,
      "note": note,
      "status": status,
      if (metadata != null && metadata.isNotEmpty) "metadata": metadata,
    };

    final baseUrl = isBranchManager ? ApiConstants.branchManagerCrmLeadCreate : ApiConstants.businessOwnerCrmLeadCreate;
    final response = await networkClient.postRequest(
      baseUrl,
      body: body,
    );

    if (response.isSuccess) {
      return {
        'success': true,
        'message': response.responseData?['message'] ?? 'Lead created successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage,
      };
    }
  }

  Future<Map<String, dynamic>> updateLead({
    required String id,
    String? branchId,
    String? name,
    String? email,
    String? phone,
    String? source,
    String? address,
    String? note,
    String? status,
    Map<String, dynamic>? metadata,
    bool isBranchManager = false,
  }) async {
    final baseUrl = isBranchManager ? ApiConstants.branchManagerCrmLead : ApiConstants.businessOwnerCrmLead;
    final url = '$baseUrl/$id';
    
    final body = <String, dynamic>{};
    if (branchId != null) body['branchId'] = branchId;
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (source != null) body['source'] = source;
    if (address != null) body['address'] = address;
    if (note != null) body['note'] = note;
    if (status != null) body['status'] = status;
    if (metadata != null) body['metadata'] = metadata;

    final response = await networkClient.patchRequest(url, body: body);

    if (response.isSuccess) {
      return {
        'success': true,
        'message': response.responseData?['message'] ?? 'Lead updated successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage,
      };
    }
  }

  Future<Map<String, dynamic>> deleteLead({required String id, bool isBranchManager = false}) async {
    final baseUrl = isBranchManager ? ApiConstants.branchManagerCrmLead : ApiConstants.businessOwnerCrmLead;
    final url = '$baseUrl/$id';
    final response = await networkClient.deleteRequest(url);

    if (response.isSuccess) {
      return {
        'success': true,
        'message': response.responseData?['message'] ?? 'Lead deleted successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.errorMassage,
      };
    }
  }

  Future<Map<String, dynamic>> getCrmCountries(String branchId, {bool isBranchManager = false}) async {
    try {
      final endpoint = isBranchManager 
          ? ApiConstants.branchManagerBookingCountries 
          : ApiConstants.businessOwnerBookingCountries;
      final url = '$endpoint?branchId=$branchId';
      final response = await networkClient.getRequest(url);

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to get CRM countries',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getCrmProductTypes(String branchId, {bool isBranchManager = false}) async {
    try {
      final endpoint = isBranchManager 
          ? ApiConstants.branchManagerCrmProductTypes 
          : ApiConstants.businessOwnerCrmProductTypes;
      final url = isBranchManager ? endpoint : '$endpoint?branchId=$branchId';
      final response = await networkClient.getRequest(url);

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to get CRM product types',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
