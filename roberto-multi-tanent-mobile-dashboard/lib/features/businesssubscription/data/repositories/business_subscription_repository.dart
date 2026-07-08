import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/businesssubscription/data/models/business_subscription_model.dart';

class BusinessSubscriptionRepository {
  final NetworkClient networkClient;

  BusinessSubscriptionRepository({required this.networkClient});

  Future<List<BusinessSubscriptionModel>> getMySubscription() async {
    final response = await networkClient.getRequest(ApiConstants.businessOwnerMySubscription);

    if (response.isSuccess) {
      final List<dynamic> data = response.responseData['data'] ?? [];
      return data.map((json) => BusinessSubscriptionModel.fromJson(json)).toList();
    } else {
      throw Exception(response.errorMassage ?? 'Failed to load subscriptions');
    }
  }

  Future<String> createCheckoutSession({
    required String planId,
    required String billingCycle,
  }) async {
    final response = await networkClient.postRequest(
      ApiConstants.createCheckoutSession,
      body: {
        'planId': planId,
        'billingCycle': billingCycle.toLowerCase(),
      },
    );

    if (response.isSuccess) {
      final data = response.responseData['data'] ?? {};
      return data['url'] ?? '';
    } else {
      throw Exception(response.errorMassage ?? 'Failed to create checkout session');
    }
  }
}
