import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/management/data/models/branch_manager_model.dart';

class ManagementRepository {
  final NetworkClient networkClient;

  ManagementRepository({required this.networkClient});

  Future<List<BranchManagerModel>> getBranchManagers() async {
    final response = await networkClient.getRequest(ApiConstants.businessOwnerBranchManagers);

    if (response.isSuccess) {
      final List<dynamic> data = response.responseData['data'] ?? [];
      return data.map((json) => BranchManagerModel.fromJson(json)).toList();
    } else {
      throw Exception(response.errorMassage ?? 'Failed to load branch managers');
    }
  }

  Future<BranchManagerModel> createBranchManager({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await networkClient.postRequest(
      ApiConstants.businessOwnerBranchManagersCreate,
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response.isSuccess) {
      return BranchManagerModel.fromJson(response.responseData['data']);
    } else {
      throw Exception(response.errorMassage ?? 'Failed to create branch manager');
    }
  }

  Future<void> deleteBranchManager(String id) async {
    final response = await networkClient.deleteRequest(
      '${ApiConstants.businessOwnerBranchManagersDelete}/$id',
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMassage ?? 'Failed to delete branch manager');
    }
  }
}
