import 'package:equatable/equatable.dart';

abstract class AgentManagementEvent extends Equatable {
  const AgentManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchAgentsRequested extends AgentManagementEvent {
  const FetchAgentsRequested();
}

class CreateAgentRequested extends AgentManagementEvent {
  final String businessId;
  final String agentName;
  final String branchId;
  // rules_file (PDF/Word)
  final String? filePath;
  final List<int>? fileBytes;
  final String? fileName;
  // productFile (Excel)
  final String? productFilePath;
  final List<int>? productFileBytes;
  final String? productFileName;

  const CreateAgentRequested({
    required this.businessId,
    required this.agentName,
    required this.branchId,
    this.filePath,
    this.fileBytes,
    this.fileName,
    this.productFilePath,
    this.productFileBytes,
    this.productFileName,
  });

  @override
  List<Object?> get props => [
    businessId,
    agentName,
    branchId,
    filePath,
    fileBytes,
    fileName,
    productFilePath,
    productFileBytes,
    productFileName,
  ];
}

class UpdateAgentRequested extends AgentManagementEvent {
  final String id;
  final String businessId;
  final String agentName;
  final String? filePath;
  final List<int>? fileBytes;
  final String? fileName;

  const UpdateAgentRequested({
    required this.id,
    required this.businessId,
    required this.agentName,
    this.filePath,
    this.fileBytes,
    this.fileName,
  });

  @override
  List<Object?> get props => [id, businessId, agentName, filePath, fileBytes, fileName];
}

/// Updates only the productFile (Excel) for an existing agent.
/// Uses PATCH /system-owner/agent-management/:id with agentId + productFile.
class UpdateProductFileRequested extends AgentManagementEvent {
  final String id;       // agent DB id (used in URL path)
  final String vapiId;   // agentId field in body
  final String? filePath;
  final List<int>? fileBytes;
  final String? fileName;

  const UpdateProductFileRequested({
    required this.id,
    required this.vapiId,
    this.filePath,
    this.fileBytes,
    this.fileName,
  });

  @override
  List<Object?> get props => [id, vapiId, filePath, fileBytes, fileName];
}

class DeleteAgentRequested extends AgentManagementEvent {
  final String id;

  const DeleteAgentRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class SetupTwilioRequested extends AgentManagementEvent {
  final String twilioSid;
  final String twilioAuthToken;
  final String twilioNumber;
  final String transferNumber;
  final String assistantId;

  const SetupTwilioRequested({
    required this.twilioSid,
    required this.twilioAuthToken,
    required this.twilioNumber,
    required this.transferNumber,
    required this.assistantId,
  });

  @override
  List<Object> get props => [
    twilioSid,
    twilioAuthToken,
    twilioNumber,
    transferNumber,
    assistantId,
  ];
}
