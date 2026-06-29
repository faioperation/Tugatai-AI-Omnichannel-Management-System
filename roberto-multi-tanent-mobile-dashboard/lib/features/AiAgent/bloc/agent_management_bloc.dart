import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/AiAgent/data/repositories/agent_repository.dart';
import 'package:roberto/features/AiAgent/bloc/agent_management_event.dart';
import 'package:roberto/features/AiAgent/bloc/agent_management_state.dart';

class AgentManagementBloc
    extends Bloc<AgentManagementEvent, AgentManagementState> {
  final AgentRepository repository;

  AgentManagementBloc({required this.repository})
    : super(AgentManagementInitial()) {
    on<FetchAgentsRequested>(_onFetchAgents);
    on<CreateAgentRequested>(_onCreateAgent);
    on<UpdateAgentRequested>(_onUpdateAgent);
    on<DeleteAgentRequested>(_onDeleteAgent);
    on<SetupTwilioRequested>(_onSetupTwilio);
  }

  Future<void> _onFetchAgents(
    FetchAgentsRequested event,
    Emitter<AgentManagementState> emit,
  ) async {
    emit(AgentManagementLoading());
    try {
      final response = await repository.getAllAgents();
      emit(AgentManagementLoaded(response.agents));
    } catch (e) {
      emit(AgentManagementError(e.toString()));
    }
  }

  Future<void> _onCreateAgent(
    CreateAgentRequested event,
    Emitter<AgentManagementState> emit,
  ) async {
    emit(AgentManagementLoading());
    try {
      await repository.createAgent(
        businessId: event.businessId,
        agentName: event.agentName,
        branchId: event.branchId,
        filePath: event.filePath,
        fileBytes: event.fileBytes,
        fileName: event.fileName,
      );
      emit(const AgentManagementOperationSuccess("Agent created successfully"));
      add(const FetchAgentsRequested());
    } catch (e) {
      emit(AgentManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateAgent(
    UpdateAgentRequested event,
    Emitter<AgentManagementState> emit,
  ) async {
    emit(AgentManagementLoading());
    try {
      await repository.updateAgent(
        id: event.id,
        businessId: event.businessId,
        agentName: event.agentName,
        filePath: event.filePath,
        fileBytes: event.fileBytes,
        fileName: event.fileName,
      );
      emit(const AgentManagementOperationSuccess("Agent updated successfully"));
      add(const FetchAgentsRequested());
    } catch (e) {
      emit(AgentManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteAgent(
    DeleteAgentRequested event,
    Emitter<AgentManagementState> emit,
  ) async {
    emit(AgentManagementLoading());
    try {
      await repository.deleteAgent(event.id);
      emit(const AgentManagementOperationSuccess("Agent deleted successfully"));
      add(const FetchAgentsRequested());
    } catch (e) {
      emit(AgentManagementError(e.toString()));
    }
  }

  Future<void> _onSetupTwilio(
    SetupTwilioRequested event,
    Emitter<AgentManagementState> emit,
  ) async {
    emit(AgentManagementLoading());
    try {
      await repository.setupTwilio(
        twilioSid: event.twilioSid,
        twilioAuthToken: event.twilioAuthToken,
        twilioNumber: event.twilioNumber,
        transferNumber: event.transferNumber,
        assistantId: event.assistantId,
      );
      emit(
        const AgentManagementOperationSuccess(
          "Twilio configuration updated successfully",
        ),
      );
      add(const FetchAgentsRequested());
    } catch (e) {
      emit(AgentManagementError(e.toString()));
    }
  }
}
