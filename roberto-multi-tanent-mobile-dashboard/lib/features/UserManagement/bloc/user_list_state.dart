import '../data/models/user_list_model.dart';

abstract class UserListState {}

class UserListInitial extends UserListState {}

class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState {
  final List<UserModel> users;

  UserListLoaded(this.users);
}

class UserListError extends UserListState {
  final String message;

  UserListError(this.message);
}
