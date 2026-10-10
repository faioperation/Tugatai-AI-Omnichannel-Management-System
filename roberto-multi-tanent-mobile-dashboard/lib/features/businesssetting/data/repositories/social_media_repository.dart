import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';

class SocialMediaRepository {
  final NetworkClient networkClient;

  SocialMediaRepository({required this.networkClient});

  Future<String?> getFacebookAuthUrl(String branchId) async {
    final response = await networkClient.getRequest(
      '${ApiConstants.facebookAuth}?branchId=$branchId',
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true && response.responseData['data'] != null) {
        return response.responseData['data']['url'];
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getFacebookStatus(String branchId) async {
    final response = await networkClient.getRequest(
      '${ApiConstants.facebookStatus}?branchId=$branchId',
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final connected = response.responseData['connected'] ?? false;
        String? id;
        if (connected && response.responseData['data'] != null) {
          final data = response.responseData['data'];
          if (data is List && data.isNotEmpty) {
            final dataObj = data[0];
            id = dataObj['id'] ?? dataObj['accountId'] ?? dataObj['connectionId'];
          } else if (data is Map) {
            id = data['id'] ?? data['accountId'] ?? data['connectionId'];
          }
        }
        return {'connected': connected, 'id': id};
      }
    }
    return {'connected': false, 'id': null};
  }

  Future<bool> disconnectFacebook(String connectionId) async {
    final response = await networkClient.postRequest(
      ApiConstants.facebookDisconnect,
      body: {'connectionId': connectionId},
    );
    return response.isSuccess && (response.responseData?['success'] == true);
  }

  Future<String?> getInstagramAuthUrl(String branchId) async {
    final response = await networkClient.getRequest(
      '${ApiConstants.instagramAuth}?branchId=$branchId',
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true && response.responseData['data'] != null) {
        return response.responseData['data']['url'];
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getInstagramStatus(String branchId) async {
    final response = await networkClient.getRequest(
      '${ApiConstants.instagramStatus}?branchId=$branchId',
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final connected = response.responseData['connected'] ?? false;
        String? id;
        if (connected && response.responseData['data'] != null) {
          final data = response.responseData['data'];
          if (data is List && data.isNotEmpty) {
            final dataObj = data[0];
            id = dataObj['id'] ?? dataObj['accountId'] ?? dataObj['connectionId'];
          } else if (data is Map) {
            id = data['id'] ?? data['accountId'] ?? data['connectionId'];
          }
        }
        return {'connected': connected, 'id': id};
      }
    }
    return {'connected': false, 'id': null};
  }

  Future<bool> disconnectInstagram(String connectionId) async {
    final response = await networkClient.postRequest(
      ApiConstants.instagramDisconnect,
      body: {'connectionId': connectionId},
    );
    return response.isSuccess && (response.responseData?['success'] == true);
  }

  Future<String?> getWhatsAppAuthUrl(String branchId) async {
    final response = await networkClient.getRequest(
      '${ApiConstants.whatsappAuth}?branchId=$branchId',
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true && response.responseData['data'] != null) {
        return response.responseData['data']['url'];
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getWhatsAppStatus(String branchId) async {
    final response = await networkClient.getRequest(
      '${ApiConstants.whatsappStatus}?branchId=$branchId',
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final connected = response.responseData['connected'] ?? false;
        String? id;
        String? connectionType;
        if (connected && response.responseData['data'] != null) {
          final data = response.responseData['data'];
          if (data is List && data.isNotEmpty) {
            final dataObj = data[0];
            id = dataObj['id'] ?? dataObj['accountId'] ?? dataObj['connectionId'];
            connectionType = dataObj['connectionType'];
          } else if (data is Map) {
            id = data['id'] ?? data['accountId'] ?? data['connectionId'];
            connectionType = data['connectionType'];
          }
        }
        return {'connected': connected, 'id': id, 'connectionType': connectionType};
      }
    }
    return {'connected': false, 'id': null, 'connectionType': null};
  }

  Future<bool> disconnectWhatsApp(String accountId, {String? branchId}) async {
    final response = await networkClient.postRequest(
      ApiConstants.whatsappDisconnect,
      body: {
        if (accountId.isNotEmpty) 'accountId': accountId,
        if (branchId != null && branchId.isNotEmpty) 'branchId': branchId,
      },
    );
    return response.isSuccess && (response.responseData?['success'] == true);
  }

  Future<Map<String, dynamic>> connectWhatsAppQr(String branchId) async {
    final response = await networkClient.postRequest(
      ApiConstants.whatsappQrConnect,
      body: {'branchId': branchId.isNotEmpty ? branchId : null},
    );
    if (response.isSuccess && response.responseData != null && response.responseData['success'] == true) {
      return Map<String, dynamic>.from(response.responseData['data'] ?? {});
    }
    return {};
  }

  Future<Map<String, dynamic>> getWhatsAppQrStatus(String instanceName) async {
    final response = await networkClient.getRequest(
      '${ApiConstants.whatsappQrStatus}?instanceName=$instanceName',
    );
    if (response.isSuccess && response.responseData != null && response.responseData['success'] == true) {
      return Map<String, dynamic>.from(response.responseData['data'] ?? {});
    }
    return {};
  }

  Future<String?> getGoogleCalendarAuthUrl(String branchId) async {
    final response = await networkClient.getRequest(
      '${ApiConstants.googleCalendarConnect}?branchId=$branchId',
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true && response.responseData['data'] != null) {
        return response.responseData['data']['url'];
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getGoogleCalendarStatus(String branchId) async {
    final response = await networkClient.getRequest(
      '${ApiConstants.googleCalendarStatus}?branchId=$branchId',
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        final data = response.responseData['data'];
        if (data != null) {
          return {
            'connected': data['isConnected'] ?? false,
            'email': data['email']
          };
        }
      }
    }
    return {'connected': false, 'email': null};
  }

  Future<bool> disconnectGoogleCalendar(String branchId) async {
    final response = await networkClient.postRequest(
      ApiConstants.googleCalendarDisconnect,
      body: {'branchId': branchId},
    );
    return response.isSuccess && (response.responseData?['success'] == true);
  }
}
