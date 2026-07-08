import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Auth/data/repositories/auth_repository.dart';

import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository authRepository;

  ForgotPasswordBloc({required this.authRepository}) : super(ForgotPasswordInitial()) {
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      final message = await authRepository.forgotPassword(email: event.email);
      emit(ForgotPasswordOtpSent(message: message));
    } catch (e) {
      emit(ForgotPasswordFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      await authRepository.verifyOtp(email: event.email, otp: event.otp);
      emit(ForgotPasswordOtpVerified());
    } catch (e) {
      emit(ForgotPasswordFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      await authRepository.resetPassword(newPassword: event.newPassword);
      emit(ForgotPasswordResetSuccess());
    } catch (e) {
      emit(ForgotPasswordFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
