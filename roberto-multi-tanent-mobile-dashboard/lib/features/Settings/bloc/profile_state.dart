import 'package:flutter/foundation.dart';
import 'package:roberto/features/Auth/data/models/user_model.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;

  ProfileLoaded({required this.user});
}

class ProfileUpdating extends ProfileState {
  final UserModel currentUser;

  ProfileUpdating({required this.currentUser});
}

class ProfileUpdateSuccess extends ProfileState {
  final UserModel user;

  ProfileUpdateSuccess({required this.user});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}

class PasswordChanging extends ProfileState {
  final UserModel currentUser;
  PasswordChanging({required this.currentUser});
}

class PasswordChangeSuccess extends ProfileState {
  final UserModel user;
  PasswordChangeSuccess({required this.user});
}

class PasswordChangeError extends ProfileState {
  final String message;
  final UserModel currentUser;
  PasswordChangeError({required this.message, required this.currentUser});
}
