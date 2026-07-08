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
    // rules_file
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    // productFile (Excel)
    String? productFilePath,
    List<int>? productFileBytes,
    String? productFileName,
  }) async {
    final Map<String, String> body = {
      'businessId': businessId,
      'agentName': agentName,
      'branchId': branchId,
    };

    final Map<String, String> files = {};
    final Map<String, List<int>> fileBytesMap = {};
    final Map<String, String> fileNamesMap = {};

    if (filePath != null && filePath.isNotEmpty) {
      files['rules_file'] = filePath;
    } else if (fileBytes != null) {
      fileBytesMap['rules_file'] = fileBytes;
      if (fileName != null) fileNamesMap['rules_file'] = fileName;
    }

    if (productFilePath != null && productFilePath.isNotEmpty) {
      files['productFile'] = productFilePath;
    } else if (productFileBytes != null) {
      fileBytesMap['productFile'] = productFileBytes;
      if (productFileName != null) fileNamesMap['productFile'] = productFileName;
    }

    final response = await networkClient.postMultipartRequest(
      ApiConstants.systemOwnerAgentManagementCreate,
      body: body,
      files: files.isNotEmpty ? files : null,
      fileBytes: fileBytesMap.isNotEmpty ? fileBytesMap : null,
      fileNames: fileNamesMap.isNotEmpty ? fileNamesMap : null,
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

    final Map<String, String> files = {};
    final Map<String, List<int>> fileBytesMap = {};
    final Map<String, String> fileNamesMap = {};

    if (filePath != null && filePath.isNotEmpty) {
      files['rules_file'] = filePath;
    } else if (fileBytes != null) {
      fileBytesMap['rules_file'] = fileBytes;
      if (fileName != null) fileNamesMap['rules_file'] = fileName;
    }

    final response = await networkClient.patchMultipartRequest(
      '${ApiConstants.systemOwnerAgentManagementSingle}/$id',
      body: body,
      files: files.isNotEmpty ? files : null,
      fileBytes: fileBytesMap.isNotEmpty ? fileBytesMap : null,
      fileNames: fileNamesMap.isNotEmpty ? fileNamesMap : null,
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

  /// Updates only the productFile (Excel) for an existing agent.
  /// PATCH /system-owner/agent-management/:id  with agentId + productFile
  Future<void> updateProductFile({
    required String id,
    required String vapiId,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final Map<String, String> body = {
      'agentId': vapiId,
    };

    final Map<String, String> files = {};
    final Map<String, List<int>> fileBytesMap = {};
    final Map<String, String> fileNamesMap = {};

    if (filePath != null && filePath.isNotEmpty) {
      files['productFile'] = filePath;
    } else if (fileBytes != null) {
      fileBytesMap['productFile'] = fileBytes;
      if (fileName != null) fileNamesMap['productFile'] = fileName;
    }

    final response = await networkClient.patchMultipartRequest(
      '${ApiConstants.systemOwnerAgentManagementSingle}/$id',
      body: body,
      files: files.isNotEmpty ? files : null,
      fileBytes: fileBytesMap.isNotEmpty ? fileBytesMap : null,
      fileNames: fileNamesMap.isNotEmpty ? fileNamesMap : null,
    );

    if (response.isSuccess && response.responseData != null) {
      if (response.responseData['success'] == true) {
        return;
      } else {
        throw Exception(
          response.responseData['message'] ?? 'Failed to update product file.',
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
