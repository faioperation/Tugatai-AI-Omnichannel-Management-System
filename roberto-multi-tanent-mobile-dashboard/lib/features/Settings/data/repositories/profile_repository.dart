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

  Future<UserModel> updateProfile({required String firstName, required String lastName, String? avatarPath, List<int>? avatarBytes, String? avatarName}) async {
    final body = {
      'firstName': firstName,
      'lastName': lastName,
    };
    
    final files = <String, String>{};
    if (avatarPath != null && avatarPath.isNotEmpty && avatarBytes == null) {
      files['avatar'] = avatarPath;
    }

    final fileBytes = <String, List<int>>{};
    final fileNames = <String, String>{};
    if (avatarBytes != null) {
      fileBytes['avatar'] = avatarBytes;
      if (avatarName != null) {
        fileNames['avatar'] = avatarName;
      }
    }

    final response = await networkClient.patchMultipartRequest(
      ApiConstants.updateProfile,
      body: body,
      files: files.isNotEmpty ? files : null,
      fileBytes: fileBytes.isNotEmpty ? fileBytes : null,
      fileNames: fileNames.isNotEmpty ? fileNames : null,
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
