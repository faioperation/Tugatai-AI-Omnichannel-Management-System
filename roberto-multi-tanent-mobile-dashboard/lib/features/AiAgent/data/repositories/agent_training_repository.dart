import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/services/local_storage_service.dart';
import 'package:roberto/features/AiAgent/data/models/agent_training_model.dart';

class AgentTrainingRepository {
  Future<String?> _getToken() async {
    return LocalStorageService.accessToken;
  }

  Future<AgentTrainingResponse> getAllTrainings({int page = 1, int limit = 10}) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.systemOwnerAgentTrainings}?page=$page&limit=$limit');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return AgentTrainingResponse.fromJson(decoded);
    } else {
      throw Exception('Failed to load agent trainings: ${response.statusCode}');
    }
  }

  Future<AgentTraining> getTrainingById(String id) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.systemOwnerAgentTrainingsSingle}/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return AgentTraining.fromJson(decoded['data']);
    } else {
      throw Exception('Failed to load agent training: ${response.statusCode}');
    }
  }

  Future<AgentTraining> createTraining({
    required String businessId,
    required String systemPrompt,
    String? businessInformation,
    dynamic productInformationFile,
    dynamic policiesGuidelinesFile,
    dynamic faqFile,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConstants.systemOwnerAgentTrainingsCreate);
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['businessId'] = businessId
      ..fields['systemPrompt'] = systemPrompt;

    if (businessInformation != null) {
      request.fields['businessInformation'] = businessInformation;
    }

    // Since we don't have dart:io available for web by default easily with MultipartFile.fromPath,
    // we use fromBytes for cross-platform (if passing bytes)
    // Here we will assume file objects are not being uploaded yet, just text.
    // If you pass real files in the UI, you would use http.MultipartFile.fromBytes
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return AgentTraining.fromJson(decoded['data']);
    } else {
      throw Exception('Failed to create agent training: ${response.body}');
    }
  }

  Future<AgentTraining> updateTraining(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.systemOwnerAgentTrainingsSingle}/$id');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return AgentTraining.fromJson(decoded['data']);
    } else {
      throw Exception('Failed to update agent training: ${response.body}');
    }
  }

  Future<void> deleteTraining(String id) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConstants.systemOwnerAgentTrainingsSingle}/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete agent training: ${response.body}');
    }
  }
}
