import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/Auth/data/models/user_model.dart';
import 'package:roberto/core/services/local_storage_service.dart';

class AuthRepository {
  final NetworkClient networkClient;

  AuthRepository({required this.networkClient});

  Future<UserModel> login({required String email, required String password}) async {
    final response = await networkClient.postRequest(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.isSuccess && response.responseData != null) {
      final responseData = response.responseData;
      if (responseData['success'] == true) {
        final data = responseData['data'];
        
        // Extract tokens
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        if (accessToken != null && refreshToken != null) {
          await LocalStorageService.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }

        // Parse user data
        final userData = data['user'];
        if (userData != null) {
          return UserModel.fromJson(userData);
        } else {
          throw Exception("User data is missing from the response.");
        }
      } else {
        throw Exception(responseData['message'] ?? 'Login failed.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<String> forgotPassword({required String email}) async {
    final response = await networkClient.postRequest(
      ApiConstants.forgotPassword,
      body: {'email': email},
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return response.responseData['message'] ?? 'OTP sent successfully.';
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to send OTP.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    final response = await networkClient.postRequest(
      ApiConstants.verifyOtp,
      body: {'email': email, 'otp': otp},
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        // Assume verify might also return an access token for reset password
        final data = response.responseData['data'];
        if (data != null && data is Map) {
          final accessToken = data['accessToken'];
          if (accessToken != null) {
            await LocalStorageService.saveTokens(
              accessToken: accessToken,
              refreshToken: LocalStorageService.refreshToken ?? '',
            );
          }
        }
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to verify OTP.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> resetPassword({required String newPassword}) async {
    final response = await networkClient.postRequest(
      ApiConstants.resetPassword,
      body: {'newPassword': newPassword},
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] != true) {
        throw Exception(response.responseData['message'] ?? 'Failed to reset password.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> refreshToken({required String email, required String password}) async {
    final response = await networkClient.postRequest(
      ApiConstants.refreshToken,
      body: {'email': email, 'password': password},
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final data = response.responseData['data'];
        if (data != null) {
          final accessToken = data['accessToken'];
          if (accessToken != null) {
            await LocalStorageService.saveTokens(
              accessToken: accessToken,
              refreshToken: LocalStorageService.refreshToken ?? '',
            );
          }
        }
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to refresh token.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }
}
