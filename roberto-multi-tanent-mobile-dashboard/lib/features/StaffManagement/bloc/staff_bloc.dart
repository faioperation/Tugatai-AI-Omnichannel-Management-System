import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/staff_repository.dart';
import '../data/models/staff_user_model.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository repository;
  List<StaffUserModel> _currentStaffUsers = [];
  List<PermissionModel> _currentPermissions = [];

  StaffBloc({required this.repository}) : super(StaffInitial()) {
    on<FetchAllStaffRequested>(_onFetchAllStaffRequested);
    on<FetchPermissionsRequested>(_onFetchPermissionsRequested);
    on<CreateStaffRequested>(_onCreateStaffRequested);
    on<UpdateStaffPermissionsRequested>(_onUpdateStaffPermissionsRequested);
    on<DeleteStaffRequested>(_onDeleteStaffRequested);
  }

  Future<void> _onFetchAllStaffRequested(
    FetchAllStaffRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());
    try {
      final staffUsers = await repository.fetchAllStaff();
      _currentStaffUsers = staffUsers;
      if (_currentPermissions.isEmpty) {
        _currentPermissions = await repository.fetchAssignablePermissions();
      }
      emit(StaffLoaded(
        staffUsers: _currentStaffUsers,
        availablePermissions: _currentPermissions,
      ));
    } catch (e) {
      emit(StaffError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchPermissionsRequested(
    FetchPermissionsRequested event,
    Emitter<StaffState> emit,
  ) async {
    try {
      _currentPermissions = await repository.fetchAssignablePermissions();
      emit(StaffLoaded(
        staffUsers: _currentStaffUsers,
        availablePermissions: _currentPermissions,
      ));
    } catch (e) {
      emit(StaffError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateStaffRequested(
    CreateStaffRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());
    try {
      await repository.createStaffUser(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        permissions: event.permissions,
      );
      emit(StaffOperationSuccess("System Staff user created successfully"));
      add(FetchAllStaffRequested());
    } catch (e) {
      emit(StaffError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateStaffPermissionsRequested(
    UpdateStaffPermissionsRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());
    try {
      await repository.updateStaffPermissions(
        staffId: event.staffId,
        permissions: event.permissions,
      );
      emit(StaffOperationSuccess("Staff permissions updated successfully"));
      add(FetchAllStaffRequested());
    } catch (e) {
      emit(StaffError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteStaffRequested(
    DeleteStaffRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());
    try {
      await repository.deleteStaffUser(event.staffId);
      emit(StaffOperationSuccess("System Staff user deleted successfully"));
      add(FetchAllStaffRequested());
    } catch (e) {
      emit(StaffError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
