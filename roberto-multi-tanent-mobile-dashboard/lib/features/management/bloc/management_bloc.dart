import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/management/bloc/management_event.dart';
import 'package:roberto/features/management/bloc/management_state.dart';
import 'package:roberto/features/management/data/repositories/management_repository.dart';

class ManagementBloc extends Bloc<ManagementEvent, ManagementState> {
  final ManagementRepository repository;

  ManagementBloc({required this.repository}) : super(ManagementInitial()) {
    on<FetchBranchManagersRequested>(_onFetchBranchManagers);
    on<CreateBranchManagerRequested>(_onCreateBranchManager);
    on<DeleteBranchManagerRequested>(_onDeleteBranchManager);
  }

  Future<void> _onFetchBranchManagers(
    FetchBranchManagersRequested event,
    Emitter<ManagementState> emit,
  ) async {
    emit(ManagementLoading());
    try {
      final managers = await repository.getBranchManagers();
      emit(ManagementLoaded(managers: managers));
    } catch (e) {
      emit(ManagementError(message: e.toString()));
    }
  }

  Future<void> _onCreateBranchManager(
    CreateBranchManagerRequested event,
    Emitter<ManagementState> emit,
  ) async {
    emit(ManagementLoading());
    try {
      await repository.createBranchManager(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(const ManagementOperationSuccess(message: "Branch Manager created successfully"));
      add(FetchBranchManagersRequested());
    } catch (e) {
      emit(ManagementError(message: e.toString()));
    }
  }

  Future<void> _onDeleteBranchManager(
    DeleteBranchManagerRequested event,
    Emitter<ManagementState> emit,
  ) async {
    emit(ManagementLoading());
    try {
      await repository.deleteBranchManager(event.id);
      emit(const ManagementOperationSuccess(message: "Branch Manager deleted successfully"));
      add(FetchBranchManagersRequested());
    } catch (e) {
      emit(ManagementError(message: e.toString()));
    }
  }
}
