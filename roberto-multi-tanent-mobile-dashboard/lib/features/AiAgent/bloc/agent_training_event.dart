import 'package:equatable/equatable.dart';

abstract class AgentTrainingEvent extends Equatable {
  const AgentTrainingEvent();

  @override
  List<Object?> get props => [];
}

class FetchAgentTrainingsRequested extends AgentTrainingEvent {
  final int page;
  final int limit;

  const FetchAgentTrainingsRequested({this.page = 1, this.limit = 10});

  @override
  List<Object> get props => [page, limit];
}

class FetchAgentTrainingByBusinessRequested extends AgentTrainingEvent {
  final String businessId;

  const FetchAgentTrainingByBusinessRequested({required this.businessId});

  @override
  List<Object> get props => [businessId];
}

class CreateAgentTrainingRequested extends AgentTrainingEvent {
  final String businessId;
  final String systemPrompt;
  final String? businessInformation;
  final dynamic productInformationFile;
  final dynamic policiesGuidelinesFile;
  final dynamic faqFile;

  const CreateAgentTrainingRequested({
    required this.businessId,
    required this.systemPrompt,
    this.businessInformation,
    this.productInformationFile,
    this.policiesGuidelinesFile,
    this.faqFile,
  });

  @override
  List<Object?> get props => [
    businessId,
    systemPrompt,
    businessInformation,
    productInformationFile,
    policiesGuidelinesFile,
    faqFile,
  ];
}

class UpdateAgentTrainingRequested extends AgentTrainingEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdateAgentTrainingRequested({required this.id, required this.data});

  @override
  List<Object> get props => [id, data];
}
