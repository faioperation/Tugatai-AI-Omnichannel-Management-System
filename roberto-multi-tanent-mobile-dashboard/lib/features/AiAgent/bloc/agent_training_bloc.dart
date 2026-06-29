import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/AiAgent/data/repositories/agent_training_repository.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_event.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_state.dart';

class AgentTrainingBloc extends Bloc<AgentTrainingEvent, AgentTrainingState> {
  final AgentTrainingRepository repository;

  AgentTrainingBloc({required this.repository})
    : super(AgentTrainingInitial()) {
    on<FetchAgentTrainingsRequested>(_onFetchAgentTrainings);
    on<FetchAgentTrainingByBusinessRequested>(_onFetchAgentTrainingByBusiness);
    on<CreateAgentTrainingRequested>(_onCreateAgentTraining);
    on<UpdateAgentTrainingRequested>(_onUpdateAgentTraining);
  }

  Future<void> _onFetchAgentTrainings(
    FetchAgentTrainingsRequested event,
    Emitter<AgentTrainingState> emit,
  ) async {
    emit(AgentTrainingLoading());
    try {
      final response = await repository.getAllTrainings(
        page: event.page,
        limit: event.limit,
      );
      emit(AgentTrainingLoaded(response));
    } catch (e) {
      emit(AgentTrainingError(e.toString()));
    }
  }

  Future<void> _onFetchAgentTrainingByBusiness(
    FetchAgentTrainingByBusinessRequested event,
    Emitter<AgentTrainingState> emit,
  ) async {
    emit(AgentTrainingLoading());
    try {
      // The API doesn't have a direct /by-business endpoint in the screenshots,
      // but it has /all. We will fetch all and filter by businessId.
      // If there is a direct endpoint in the future, we can change this.
      final response = await repository.getAllTrainings(limit: 100);

      final training = response.trainings.cast<dynamic>().firstWhere(
        (t) => t.businessId == event.businessId,
        orElse: () => null,
      );

      if (training != null) {
        emit(SingleAgentTrainingLoaded(training));
      } else {
        // Not found for this business, emit initial or specific state
        emit(AgentTrainingInitial());
      }
    } catch (e) {
      emit(AgentTrainingError(e.toString()));
    }
  }

  Future<void> _onCreateAgentTraining(
    CreateAgentTrainingRequested event,
    Emitter<AgentTrainingState> emit,
  ) async {
    emit(AgentTrainingLoading());
    try {
      final training = await repository.createTraining(
        businessId: event.businessId,
        systemPrompt: event.systemPrompt,
        businessInformation: event.businessInformation,
        productInformationFile: event.productInformationFile,
        policiesGuidelinesFile: event.policiesGuidelinesFile,
        faqFile: event.faqFile,
      );
      emit(
        AgentTrainingOperationSuccess(
          training,
          "Agent training created successfully",
        ),
      );
      // Re-fetch or just emit loaded
      emit(SingleAgentTrainingLoaded(training));
    } catch (e) {
      emit(AgentTrainingError(e.toString()));
    }
  }

  Future<void> _onUpdateAgentTraining(
    UpdateAgentTrainingRequested event,
    Emitter<AgentTrainingState> emit,
  ) async {
    emit(AgentTrainingLoading());
    try {
      final training = await repository.updateTraining(event.id, event.data);
      emit(
        AgentTrainingOperationSuccess(
          training,
          "Agent training updated successfully",
        ),
      );
      emit(SingleAgentTrainingLoaded(training));
    } catch (e) {
      emit(AgentTrainingError(e.toString()));
    }
  }
}
