import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';

class BookingRepository {
  final NetworkClient _networkClient;
  final bool isBranchManager;

  BookingRepository({required NetworkClient networkClient, this.isBranchManager = false})
      : _networkClient = networkClient;

  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 10,
    String search = '',
    String status = '',
    String? branchId,
    String country = '',
    String productType = '',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty) 'search': search,
        if (status.isNotEmpty && status != 'All status') 'status': status.toUpperCase(),
        if (branchId != null) 'branchId': branchId,
        if (country.isNotEmpty && country != 'All countries') 'country': country,
        if (productType.isNotEmpty && productType != 'All types') 'productType': productType,
      };

      final queryString = Uri(queryParameters: queryParams).query;
      final baseUrl = isBranchManager ? ApiConstants.branchManagerBookingsAll : ApiConstants.businessOwnerBookingsAll;
      final url = '$baseUrl?$queryString';

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
      final baseUrl = isBranchManager ? ApiConstants.branchManagerBookingsCreate : '${ApiConstants.baseUrl}/business-owner/bookings/create';
      final response = await _networkClient.postRequest(
        baseUrl,
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
      final baseUrl = isBranchManager ? ApiConstants.branchManagerBookingsSingle : '${ApiConstants.baseUrl}/business-owner/bookings';
      final response = await _networkClient.patchRequest(
        '$baseUrl/$id',
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
      final baseUrl = isBranchManager ? ApiConstants.branchManagerBookingsSingle : '${ApiConstants.baseUrl}/business-owner/bookings';
      final response = await _networkClient.deleteRequest(
        '$baseUrl/$id',
      );
      if (!response.isSuccess) {
        throw Exception(response.errorMassage ?? 'Failed to delete booking');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> connectGoogleCalendar(String branchId) async {
    try {
      final url = '${ApiConstants.googleCalendarConnect}?branchId=$branchId';
      final response = await _networkClient.getRequest(url);

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to get Google Calendar connection URL',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> disconnectGoogleCalendar(String branchId) async {
    try {
      final response = await _networkClient.postRequest(
        ApiConstants.googleCalendarDisconnect,
        body: {'branchId': branchId},
      );

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to disconnect Google Calendar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getGoogleCalendarStatus(String branchId) async {
    try {
      final url = '${ApiConstants.googleCalendarStatus}?branchId=$branchId';
      final response = await _networkClient.getRequest(url);

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to get Google Calendar status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getGoogleCalendarEvents(String branchId) async {
    try {
      final url = '${ApiConstants.googleCalendarEvents}?branchId=$branchId';
      final response = await _networkClient.getRequest(url);

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to get Google Calendar events',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createGoogleCalendarEvent(Map<String, dynamic> payload) async {
    try {
      final response = await _networkClient.postRequest(
        ApiConstants.googleCalendarEvents,
        body: payload,
      );

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to create Google Calendar event',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getBookingCountries(String branchId) async {
    try {
      final endpoint = isBranchManager 
          ? ApiConstants.branchManagerBookingCountries 
          : ApiConstants.businessOwnerBookingCountries;
      final url = '$endpoint?branchId=$branchId';
      final response = await _networkClient.getRequest(url);

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to get booking countries',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getBookingProductTypes(String branchId) async {
    try {
      final endpoint = isBranchManager 
          ? ApiConstants.branchManagerBookingProductTypes 
          : ApiConstants.businessOwnerBookingProductTypes;
      // Branch manager endpoint does not require branchId query param
      final url = isBranchManager ? endpoint : '$endpoint?branchId=$branchId';
      final response = await _networkClient.getRequest(url);

      if (response.isSuccess) {
        return response.responseData is Map<String, dynamic>
            ? response.responseData as Map<String, dynamic>
            : {'success': true, 'data': response.responseData};
      } else {
        return {
          'success': false,
          'message': response.errorMassage ?? 'Failed to get booking product types',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
