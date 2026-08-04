import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_list_event.dart';
import 'user_list_state.dart';
import '../data/repositories/user_list_repository.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserListRepository repository;

  UserListBloc({required this.repository}) : super(UserListInitial()) {
    on<FetchAllUsers>((event, emit) async {
      emit(UserListLoading());
      try {
        final users = await repository.fetchAllUsers();
        emit(UserListLoaded(users));
      } catch (e) {
        emit(UserListError(e.toString()));
      }
    });
  }
}
