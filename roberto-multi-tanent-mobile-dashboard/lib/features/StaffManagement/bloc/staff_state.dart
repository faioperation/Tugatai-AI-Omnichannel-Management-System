import '../data/models/staff_user_model.dart';

abstract class StaffState {}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<StaffUserModel> staffUsers;
  final List<PermissionModel> availablePermissions;

  StaffLoaded({
    required this.staffUsers,
    required this.availablePermissions,
  });
}

class StaffOperationSuccess extends StaffState {
  final String message;
  StaffOperationSuccess(this.message);
}

class StaffError extends StaffState {
  final String message;
  StaffError(this.message);
}
