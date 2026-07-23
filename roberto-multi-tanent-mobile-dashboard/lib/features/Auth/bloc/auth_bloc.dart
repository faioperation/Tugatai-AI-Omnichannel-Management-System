import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Auth/data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    // We can emit loading state if needed, or do it silently.
    try {
      await authRepository.refreshToken(
        email: event.email,
        password: event.password,
      );
      // Optional: emit a specific success state if needed
    } catch (e) {
      // Optional: handle failure, maybe emit AuthFailure or a specific refresh failure state
    }
  }
}
