import 'package:equatable/equatable.dart';
import 'package:roberto/features/AiAgent/data/models/agent_training_model.dart';

abstract class AgentTrainingState extends Equatable {
  const AgentTrainingState();

  @override
  List<Object?> get props => [];
}

class AgentTrainingInitial extends AgentTrainingState {}

class AgentTrainingLoading extends AgentTrainingState {}

class AgentTrainingLoaded extends AgentTrainingState {
  final AgentTrainingResponse trainingResponse;

  const AgentTrainingLoaded(this.trainingResponse);

  @override
  List<Object> get props => [trainingResponse];
}

class SingleAgentTrainingLoaded extends AgentTrainingState {
  final AgentTraining training;

  const SingleAgentTrainingLoaded(this.training);

  @override
  List<Object> get props => [training];
}

class AgentTrainingOperationSuccess extends AgentTrainingState {
  final AgentTraining training;
  final String message;

  const AgentTrainingOperationSuccess(this.training, this.message);

  @override
  List<Object> get props => [training, message];
}

class AgentTrainingError extends AgentTrainingState {
  final String message;

  const AgentTrainingError(this.message);

  @override
  List<Object> get props => [message];
}
