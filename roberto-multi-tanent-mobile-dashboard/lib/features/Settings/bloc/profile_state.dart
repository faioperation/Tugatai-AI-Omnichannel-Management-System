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
