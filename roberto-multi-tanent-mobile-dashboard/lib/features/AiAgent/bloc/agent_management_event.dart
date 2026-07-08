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
  final String? filePath;
  final List<int>? fileBytes;
  final String? fileName;

  const CreateAgentRequested({
    required this.businessId,
    required this.agentName,
    required this.branchId,
    this.filePath,
    this.fileBytes,
    this.fileName,
  });

  @override
  List<Object?> get props => [
    businessId,
    agentName,
    branchId,
    filePath,
    fileBytes,
    fileName,
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
  List<Object?> get props => [
    id,
    businessId,
    agentName,
    filePath,
    fileBytes,
    fileName,
  ];
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
