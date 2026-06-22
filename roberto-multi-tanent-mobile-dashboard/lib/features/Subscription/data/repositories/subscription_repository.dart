import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/Subscription/data/models/subscription_model.dart';

class SubscriptionRepository {
  final NetworkClient networkClient;

  SubscriptionRepository({required this.networkClient});

  Future<SystemOwnerSubscriptionModel> getSystemOwnerSubscriptions() async {
    final response = await networkClient.getRequest(ApiConstants.systemOwnerSubscriptions);

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final data = response.responseData['data'];
        if (data != null) {
          return SystemOwnerSubscriptionModel.fromJson(data);
        } else {
          throw Exception('Data is missing in the response.');
        }
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to fetch subscriptions.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }
}
