import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';

class BookingRepository {
  final NetworkClient _networkClient;

  BookingRepository({required NetworkClient networkClient})
      : _networkClient = networkClient;

  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
    String? branchId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty) 'search': search,
        if (status.isNotEmpty && status != 'All status') 'status': status.toUpperCase(),
        if (branchId != null) 'branchId': branchId,
      };

      final queryString = Uri(queryParameters: queryParams).query;
      final url = '${ApiConstants.branchManagerBookingsAll}?$queryString';

      final response = await _networkClient.getRequest(url);

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to get bookings',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> payload) async {
    try {
      final response = await _networkClient.postRequest(
        ApiConstants.branchManagerBookingsCreate,
        body: payload,
      );
      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to create booking',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateBooking(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _networkClient.patchRequest(
        '${ApiConstants.branchManagerBookingsSingle}/$id',
        body: payload,
      );
      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to update booking',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<void> deleteBooking(String id) async {
    try {
      final response = await _networkClient.deleteRequest(
        '${ApiConstants.branchManagerBookingsSingle}/$id',
      );
      if (!response.isSuccess) {
        throw Exception(response.errorMassage ?? 'Failed to delete booking');
      }
    } catch (e) {
      rethrow;
    }
  }
}
