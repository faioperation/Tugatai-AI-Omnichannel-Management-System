import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Auth/data/models/user_model.dart';
import 'package:roberto/features/Settings/bloc/profile_event.dart';
import 'package:roberto/features/Settings/bloc/profile_state.dart';
import 'package:roberto/features/Settings/data/repositories/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<FetchProfileRequested>(_onFetchProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
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
      final user = await profileRepository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
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

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    UserModel? currentUser;
    if (currentState is ProfileLoaded) {
      currentUser = currentState.user;
    } else if (currentState is ProfileUpdating) {
      currentUser = currentState.currentUser;
    } else if (currentState is PasswordChangeError) {
      currentUser = currentState.currentUser;
    }

    if (currentUser == null) return;

    emit(PasswordChanging(currentUser: currentUser));
    try {
      await profileRepository.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );
      emit(PasswordChangeSuccess(user: currentUser));
      emit(ProfileLoaded(user: currentUser));
    } catch (e) {
      emit(PasswordChangeError(message: e.toString(), currentUser: currentUser));
      emit(ProfileLoaded(user: currentUser));
    }
  }
}
