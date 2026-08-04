abstract class UserListEvent {}

class FetchAllUsers extends UserListEvent {}

class UpdateUserStatus extends UserListEvent {
  final String userId;
  final String status;

  UpdateUserStatus({required this.userId, required this.status});
}
