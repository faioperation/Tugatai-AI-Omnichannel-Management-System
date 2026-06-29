import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/TenantManagement%20/data/models/tenant_model.dart';

class TenantRepository {
  final NetworkClient networkClient;

  TenantRepository({required this.networkClient});

  Future<TenantResponse> getAllTenants({String? searchParam}) async {
    String url = ApiConstants.systemOwnerBusinesses;
    if (searchParam != null && searchParam.isNotEmpty) {
      url += '?searchParam=$searchParam';
    }
    final response = await networkClient.getRequest(url);

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return TenantResponse.fromJson(response.responseData);
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to get tenants.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> createTenant(Map<String, dynamic> payload) async {
    final response = await networkClient.postRequest(
      ApiConstants.systemOwnerBusinessCreate,
      body: payload,
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return; // Success
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to create tenant.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> updateTenant(String businessId, Map<String, dynamic> payload) async {
    final response = await networkClient.patchRequest(
      '${ApiConstants.systemOwnerBusinessSingle}/$businessId',
      body: payload,
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return; // Success
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to update tenant.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> deleteTenant(String businessId) async {
    final response = await networkClient.deleteRequest('${ApiConstants.systemOwnerBusinessSingle}/$businessId');

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return; // Success
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to delete tenant.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }
}
