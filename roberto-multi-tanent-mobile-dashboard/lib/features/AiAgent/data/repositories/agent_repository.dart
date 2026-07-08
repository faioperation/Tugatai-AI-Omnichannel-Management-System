import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/network/network_client.dart';
import 'package:roberto/features/AiAgent/data/models/agent_model.dart';

class AgentRepository {
  final NetworkClient networkClient;

  AgentRepository({required this.networkClient});

  Future<AgentListResponse> getAllAgents() async {
    final response = await networkClient.getRequest(
      ApiConstants.systemOwnerAgentManagementAll,
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return AgentListResponse.fromJson(response.responseData);
      } else {
        throw Exception(
          response.responseData['message'] ?? 'Failed to load agents.',
        );
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<AgentModel> createAgent({
    required String businessId,
    required String agentName,
    required String branchId,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final Map<String, String> body = {
      'businessId': businessId,
      'agentName': agentName,
      'branchId': branchId,
    };

    final response = await networkClient.postMultipartRequest(
      ApiConstants.systemOwnerAgentManagementCreate,
      body: body,
      files: filePath != null ? {'rules_file': filePath} : null,
      fileBytes: fileBytes != null ? {'rules_file': fileBytes} : null,
      fileNames: fileName != null ? {'rules_file': fileName} : null,
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return AgentModel.fromJson(response.responseData['data']);
      } else {
        throw Exception(
          response.responseData['message'] ?? 'Failed to create agent.',
        );
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<AgentModel> updateAgent({
    required String id,
    required String businessId,
    required String agentName,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final Map<String, String> body = {
      'businessId': businessId,
      'agentName': agentName,
    };

    final response = await networkClient.patchMultipartRequest(
      '${ApiConstants.systemOwnerAgentManagementSingle}/$id',
      body: body,
      files: filePath != null ? {'rules_file': filePath} : null,
      fileBytes: fileBytes != null ? {'rules_file': fileBytes} : null,
      fileNames: fileName != null ? {'rules_file': fileName} : null,
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return AgentModel.fromJson(response.responseData['data']);
      } else {
        throw Exception(
          response.responseData['message'] ?? 'Failed to update agent.',
        );
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> deleteAgent(String id) async {
    final response = await networkClient.deleteRequest(
      '${ApiConstants.systemOwnerAgentManagementSingle}/$id',
    );
    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return;
      } else {
        throw Exception(
          response.responseData['message'] ?? 'Failed to delete agent.',
        );
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }

  Future<void> setupTwilio({
    required String twilioSid,
    required String twilioAuthToken,
    required String twilioNumber,
    required String transferNumber,
    required String assistantId,
  }) async {
    final response = await networkClient.postRequest(
      ApiConstants.systemOwnerSetupTwilio,
      body: {
        'twilio_sid': twilioSid,
        'twilio_auth_token': twilioAuthToken,
        'twilio_number': twilioNumber,
        'transfer_number': transferNumber,
        'assistant_id': assistantId,
      },
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return;
      } else {
        throw Exception(
          response.responseData['message'] ?? 'Failed to setup Twilio number.',
        );
      }
    } else {
      throw Exception(response.errorMassage ?? 'Network error occurred.');
    }
  }
}
