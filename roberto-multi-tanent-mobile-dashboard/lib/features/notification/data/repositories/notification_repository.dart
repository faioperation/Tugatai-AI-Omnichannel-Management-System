import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/notification/data/models/notification_model.dart';

class NotificationRepository {
  final NetworkClient networkClient;

  NotificationRepository({required this.networkClient});

  Future<NotificationResponse> getNotifications() async {
    final response = await networkClient.getRequest(ApiConstants.notifications);

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return NotificationResponse.fromJson(response.responseData);
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to get notifications.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> markAllAsRead() async {
    final response = await networkClient.patchRequest(ApiConstants.notificationsReadAll, body: {});

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return; // Success
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to mark all as read.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final response = await networkClient.patchRequest('${ApiConstants.notifications}/$notificationId/read', body: {});

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return; // Success
      } else {
        throw Exception(response.responseData['message'] ?? 'Failed to mark as read.');
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }
}
