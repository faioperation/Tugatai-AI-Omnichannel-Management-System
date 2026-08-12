import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import '../models/staff_user_model.dart';

class StaffRepository {
  final NetworkClient networkClient;

  StaffRepository({required this.networkClient});

  Future<List<StaffUserModel>> fetchAllStaff() async {
    final response = await networkClient.getRequest(ApiConstants.systemOwnerStaffAll);
    if (response.isSuccess && response.responseData != null) {
      final List dataList = response.responseData['data'] ?? [];
      return dataList.map((e) => StaffUserModel.fromJson(e)).toList();
    } else {
      throw Exception(response.errorMassage ?? 'Failed to fetch System Staff users');
    }
  }

  Future<List<PermissionModel>> fetchAssignablePermissions() async {
    final response = await networkClient.getRequest(ApiConstants.systemOwnerPermissionsAll);
    if (response.isSuccess && response.responseData != null) {
      final List dataList = response.responseData['data'] ?? [];
      return dataList.map((e) => PermissionModel.fromJson(e)).toList();
    } else {
      throw Exception(response.errorMassage ?? 'Failed to fetch assignable permissions');
    }
  }

  Future<StaffUserModel> createStaffUser({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phone,
    List<String> permissions = const [],
  }) async {
    final body = {
      'email': email,
      'password': password,
      'firstName': firstName,
      if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'permissions': permissions,
    };

    final response = await networkClient.postRequest(
      ApiConstants.systemOwnerStaffCreate,
      body: body,
    );

    if (response.isSuccess && response.responseData != null) {
      return StaffUserModel.fromJson(response.responseData['data']);
    } else {
      throw Exception(response.errorMassage ?? 'Failed to create System Staff user');
    }
  }

  Future<StaffUserModel> updateStaffPermissions({
    required String staffId,
    required List<String> permissions,
  }) async {
    final url = '${ApiConstants.systemOwnerStaffPermissions}/$staffId/permissions';
    final response = await networkClient.patchRequest(
      url,
      body: {'permissions': permissions},
    );

    if (response.isSuccess && response.responseData != null) {
      return StaffUserModel.fromJson(response.responseData['data']);
    } else {
      throw Exception(response.errorMassage ?? 'Failed to update System Staff permissions');
    }
  }
}
