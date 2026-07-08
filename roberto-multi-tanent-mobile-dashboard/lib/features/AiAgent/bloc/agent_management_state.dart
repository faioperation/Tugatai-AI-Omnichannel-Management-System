import 'package:equatable/equatable.dart';
import 'package:roberto/features/AiAgent/data/models/agent_model.dart';

abstract class AgentManagementState extends Equatable {
  const AgentManagementState();

  @override
  List<Object?> get props => [];
}

class AgentManagementInitial extends AgentManagementState {}

class AgentManagementLoading extends AgentManagementState {}

class AgentManagementLoaded extends AgentManagementState {
  final List<AgentModel> agents;

  const AgentManagementLoaded(this.agents);

  @override
  List<Object> get props => [agents];
}

class AgentManagementOperationSuccess extends AgentManagementState {
  final String message;

  const AgentManagementOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AgentManagementError extends AgentManagementState {
  final String message;

  const AgentManagementError(this.message);

  @override
  List<Object> get props => [message];
}
