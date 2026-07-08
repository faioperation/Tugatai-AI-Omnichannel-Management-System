import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/DemoBooking/data/models/demo_booking_model.dart';
import 'dart:developer';

class DemoBookingRepository {
  final NetworkClient networkClient;

  DemoBookingRepository({required this.networkClient});

  Future<DemoBookingPaginatedResponse> getDemoBookings({int page = 1, int limit = 20}) async {
    try {
      final response = await networkClient.getRequest('${ApiConstants.demoBookingsAll}?page=$page&limit=$limit');

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData;
        if (data['success'] == true) {
          final List<dynamic> rawList = data['data'] ?? [];
          final bookings = rawList.map((e) => DemoBookingModel.fromJson(e)).toList();

          final meta = data['meta'] ?? {};
          final totalPages = meta['totalPage'] ?? 1;
          final currentPage = meta['page'] ?? 1;

          return DemoBookingPaginatedResponse(
            bookings: bookings,
            totalPages: totalPages,
            currentPage: currentPage,
          );
        }
      }
      throw Exception(response.errorMassage ?? 'Failed to fetch demo bookings');
    } catch (e) {
      log('Error getting demo bookings: $e');
      rethrow;
    }
  }

  Future<void> updateDemoBookingStatus(String id, String status) async {
    try {
      final response = await networkClient.patchRequest(
        '${ApiConstants.demoBookings}/$id',
        body: {'status': status},
      );
      if (!response.isSuccess || (response.responseData != null && response.responseData['success'] != true)) {
        throw Exception(response.errorMassage ?? 'Failed to update demo booking status');
      }
    } catch (e) {
      log('Error updating demo booking status: $e');
      rethrow;
    }
  }

  Future<void> deleteDemoBooking(String id) async {
    try {
      final response = await networkClient.deleteRequest('${ApiConstants.demoBookings}/$id');
      if (!response.isSuccess || (response.responseData != null && response.responseData['success'] != true)) {
        throw Exception(response.errorMassage ?? 'Failed to delete demo booking');
      }
    } catch (e) {
      log('Error deleting demo booking: $e');
      rethrow;
    }
  }
}
