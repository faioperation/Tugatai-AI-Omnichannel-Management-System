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

    on<UpdateUserStatus>((event, emit) async {
      final currentState = state;
      if (currentState is UserListLoaded) {
        // Optimistically update the UI if needed, but here we can just show loading or just fetch again.
        // Let's just update the status through API and then refresh
        emit(UserListLoading());
        await repository.updateUserStatus(event.userId, event.status);
        add(FetchAllUsers());
      }
    });
  }
}
