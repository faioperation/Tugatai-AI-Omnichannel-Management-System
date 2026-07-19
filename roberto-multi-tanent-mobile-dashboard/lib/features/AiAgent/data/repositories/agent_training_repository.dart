import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:roberto/core/network/api_constants.dart';
import 'package:roberto/core/services/local_storage_service.dart';
import 'package:roberto/features/AiAgent/data/models/agent_training_model.dart';

class AgentTrainingRepository {
  Future<String?> _getToken() async {
    return LocalStorageService.accessToken;
  }

  Future<AgentTrainingResponse> getAllTrainings({
    int page = 1,
    int limit = 10,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(
      '${ApiConstants.systemOwnerAgentTrainings}?page=$page&limit=$limit',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
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
    final url = Uri.parse(
      '${ApiConstants.systemOwnerAgentTrainingsSingle}/$id',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return AgentTraining.fromJson(decoded['data']);
    } else {
      throw Exception('Failed to load agent training: ${response.statusCode}');
    }
  }

  Future<void> _attachFile(
    http.MultipartRequest request,
    String fieldName,
    dynamic file,
  ) async {
    if (file == null) return;
    try {
      final String fileName = file.name as String;
      final Uint8List? bytes = file.bytes as Uint8List?;
      if (bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            bytes,
            filename: fileName,
          ),
        );
      }
    } catch (e) {
      // ignore
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

    await _attachFile(request, 'productInformation', productInformationFile);
    await _attachFile(request, 'policiesGuidelines', policiesGuidelinesFile);
    await _attachFile(request, 'faq', faqFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return AgentTraining.fromJson(decoded['data']);
    } else {
      throw Exception('Failed to create agent training: ${response.body}');
    }
  }

  Future<AgentTraining> updateTraining({
    required String id,
    String? systemPrompt,
    String? businessInformation,
    dynamic productInformationFile,
    dynamic policiesGuidelinesFile,
    dynamic faqFile,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(
      '${ApiConstants.systemOwnerAgentTrainingsSingle}/$id',
    );
    final request = http.MultipartRequest('PATCH', url)
      ..headers['Authorization'] = 'Bearer $token';

    if (systemPrompt != null) {
      request.fields['systemPrompt'] = systemPrompt;
    }
    if (businessInformation != null) {
      request.fields['businessInformation'] = businessInformation;
    }

    await _attachFile(request, 'productInformation', productInformationFile);
    await _attachFile(request, 'policiesGuidelines', policiesGuidelinesFile);
    await _attachFile(request, 'faq', faqFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return AgentTraining.fromJson(decoded['data']);
    } else {
      throw Exception('Failed to update agent training: ${response.body}');
    }
  }

  Future<void> deleteTraining(String id) async {
    final token = await _getToken();
    final url = Uri.parse(
      '${ApiConstants.systemOwnerAgentTrainingsSingle}/$id',
    );
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete agent training: ${response.body}');
    }
  }
}
