import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/features/UserManagement/data/models/user_list_model.dart';

class UserListRepository {
  final NetworkClient networkClient;

  UserListRepository({required this.networkClient});

  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final response = await networkClient.getRequest('${ApiConstants.baseUrl}/user/all');
      if (response.isSuccess) {
        final List data = response.responseData?['data'] ?? [];
        return data.map((e) => UserModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
}
