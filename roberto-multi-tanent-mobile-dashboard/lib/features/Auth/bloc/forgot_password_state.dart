import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordOtpSent extends ForgotPasswordState {
  final String message;

  const ForgotPasswordOtpSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordOtpVerified extends ForgotPasswordState {}

class ForgotPasswordResetSuccess extends ForgotPasswordState {}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String message;

  const ForgotPasswordFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
