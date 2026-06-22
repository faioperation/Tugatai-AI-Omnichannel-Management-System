import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Settings/bloc/profile_event.dart';
import 'package:roberto/features/Settings/bloc/profile_state.dart';
import 'package:roberto/features/Settings/data/repositories/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<FetchProfileRequested>(_onFetchProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onFetchProfileRequested(
    FetchProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await profileRepository.getProfile();
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentUser: currentState.user));
    }

    try {
      final name = "${event.firstName} ${event.lastName}".trim();
      final user = await profileRepository.updateProfile(
        name: name,
        avatarPath: event.avatarPath,
        avatarBytes: event.avatarBytes,
        avatarName: event.avatarName,
      );
      emit(ProfileUpdateSuccess(user: user));
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
      if (currentState is ProfileLoaded) {
        // Revert back to the loaded state
        emit(ProfileLoaded(user: currentState.user));
      } else if (currentState is ProfileUpdating) {
        emit(ProfileLoaded(user: currentState.currentUser));
      }
    }
  }
}
