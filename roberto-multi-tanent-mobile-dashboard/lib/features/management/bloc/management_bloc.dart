import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/management/bloc/management_event.dart';
import 'package:roberto/features/management/bloc/management_state.dart';
import 'package:roberto/features/management/data/models/branch_manager_model.dart';
import 'package:roberto/features/management/data/models/branch_model.dart';
import 'package:roberto/features/management/data/repositories/management_repository.dart';

class ManagementBloc extends Bloc<ManagementEvent, ManagementState> {
  final ManagementRepository repository;
  List<BranchManagerModel> _managers = [];
  List<BranchModel> _branches = [];

  ManagementBloc({required this.repository}) : super(ManagementInitial()) {
    on<FetchBranchManagersRequested>(_onFetchBranchManagers);
    on<CreateBranchManagerRequested>(_onCreateBranchManager);
    on<DeleteBranchManagerRequested>(_onDeleteBranchManager);
    on<UpdateBranchManagerRequested>(_onUpdateBranchManager);
    on<FetchBranchesRequested>(_onFetchBranches);
    on<CreateBranchRequested>(_onCreateBranch);
    on<UpdateBranchRequested>(_onUpdateBranch);
    on<DeleteBranchRequested>(_onDeleteBranch);
  }

  Future<void> _onFetchBranchManagers(
    FetchBranchManagersRequested event,
    Emitter<ManagementState> emit,
  ) async {
    emit(ManagementLoading());
    try {
      _managers = await repository.getBranchManagers();
      emit(ManagementLoaded(managers: _managers, branches: _branches));
    } catch (e) {
      emit(ManagementError(message: e.toString().replaceAll('Exception: ', '')));
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
      emit(ManagementError(message: e.toString().replaceAll('Exception: ', '')));
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
      emit(ManagementError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateBranchManager(
    UpdateBranchManagerRequested event,
    Emitter<ManagementState> emit,
  ) async {
    emit(ManagementLoading());
    try {
      await repository.updateBranchManager(
        id: event.id,
        name: event.name,
        email: event.email,
        password: event.password,
        status: event.status,
      );
      emit(const ManagementOperationSuccess(message: "Branch Manager updated successfully"));
      add(FetchBranchManagersRequested());
    } catch (e) {
      emit(ManagementError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Branch CRUD Event Handlers
  Future<void> _onFetchBranches(
    FetchBranchesRequested event,
    Emitter<ManagementState> emit,
  ) async {
    emit(ManagementLoading());
    try {
      _branches = await repository.getBranches();
      emit(ManagementLoaded(managers: _managers, branches: _branches));
    } catch (e) {
      emit(ManagementError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateBranch(
    CreateBranchRequested event,
    Emitter<ManagementState> emit,
  ) async {
    emit(ManagementLoading());
    try {
      await repository.createBranch(
        name: event.name,
        email: event.email,
        phone: event.phone,
        address: event.address,
        managerId: event.managerId,
      );
      emit(const ManagementOperationSuccess(message: "Branch created successfully"));
      add(FetchBranchesRequested());
    } catch (e) {
      emit(ManagementError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateBranch(
    UpdateBranchRequested event,
    Emitter<ManagementState> emit,
  ) async {
    emit(ManagementLoading());
    try {
      await repository.updateBranch(
        id: event.id,
        name: event.name,
        email: event.email,
        phone: event.phone,
        address: event.address,
        managerId: event.managerId,
      );
      emit(const ManagementOperationSuccess(message: "Branch updated successfully"));
      add(FetchBranchesRequested());
    } catch (e) {
      emit(ManagementError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteBranch(
    DeleteBranchRequested event,
    Emitter<ManagementState> emit,
  ) async {
    emit(ManagementLoading());
    try {
      await repository.deleteBranch(event.id);
      emit(const ManagementOperationSuccess(message: "Branch deleted successfully"));
      add(FetchBranchesRequested());
    } catch (e) {
      emit(ManagementError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}

