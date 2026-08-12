abstract class StaffEvent {}

class FetchAllStaffRequested extends StaffEvent {}

class FetchPermissionsRequested extends StaffEvent {}

class CreateStaffRequested extends StaffEvent {
  final String email;
  final String password;
  final String firstName;
  final String? lastName;
  final String? phone;
  final List<String> permissions;

  CreateStaffRequested({
    required this.email,
    required this.password,
    required this.firstName,
    this.lastName,
    this.phone,
    this.permissions = const [],
  });
}

class UpdateStaffPermissionsRequested extends StaffEvent {
  final String staffId;
  final List<String> permissions;

  UpdateStaffPermissionsRequested({
    required this.staffId,
    required this.permissions,
  });
}
