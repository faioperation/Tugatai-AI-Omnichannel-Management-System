import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/Overview/data/models/system_overview_model.dart';
import 'package:roberto/features/Overview/data/models/business_overview_model.dart';

class OverviewRepository {
  final NetworkClient networkClient;

  OverviewRepository({required this.networkClient});

  Future<SystemOverviewModel> getSystemOwnerOverview() async {
    final response = await networkClient.getRequest(ApiConstants.systemOwnerOverview);

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final data = response.responseData['data'];
        if (data != null) {
          return SystemOverviewModel.fromJson(data);
        } else {
          throw Exception('Data is missing in the response.');
        }
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to fetch overview.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<BusinessOverviewModel> getBusinessOwnerOverview() async {
    final response = await networkClient.getRequest(ApiConstants.businessOwnerOverview);

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final data = response.responseData['data'];
        if (data != null) {
          return BusinessOverviewModel.fromJson(data);
        } else {
          throw Exception('Data is missing in the response.');
        }
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to fetch business overview.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<BusinessOverviewModel> getBranchManagerOverview() async {
    final response = await networkClient.getRequest(ApiConstants.branchManagerOverview);

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final data = response.responseData['data'];
        if (data != null) {
          return BusinessOverviewModel.fromJson(data);
        } else {
          throw Exception('Data is missing in the response.');
        }
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to fetch branch manager overview.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }
}
