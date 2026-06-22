import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/Auth/data/models/user_model.dart';

class ProfileRepository {
  final NetworkClient networkClient;

  ProfileRepository({required this.networkClient});

  Future<UserModel> getProfile() async {
    final response = await networkClient.getRequest(ApiConstants.getProfile);

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final data = response.responseData['data'];
        if (data != null) {
          return UserModel.fromJson(data);
        } else {
          throw Exception("Profile data is missing.");
        }
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to get profile.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<UserModel> updateProfile({required String name, String? avatarPath}) async {
    final body = {
      'name': name,
    };
    
    final files = <String, String>{};
    if (avatarPath != null && avatarPath.isNotEmpty) {
      files['avatar'] = avatarPath;
    }

    final response = await networkClient.patchMultipartRequest(
      ApiConstants.updateProfile,
      body: body,
      files: files,
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final data = response.responseData['data'];
        if (data != null) {
          return UserModel.fromJson(data);
        } else {
           throw Exception("Profile updated, but no data returned.");
        }
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to update profile.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }
}
