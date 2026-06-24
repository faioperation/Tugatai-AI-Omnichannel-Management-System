import 'package:equatable/equatable.dart';
import 'package:roberto/features/management/data/models/branch_manager_model.dart';

abstract class ManagementState extends Equatable {
  const ManagementState();

  @override
  List<Object?> get props => [];
}

class ManagementInitial extends ManagementState {}

class ManagementLoading extends ManagementState {}

class ManagementLoaded extends ManagementState {
  final List<BranchManagerModel> managers;

  const ManagementLoaded({required this.managers});

  @override
  List<Object?> get props => [managers];
}

class ManagementOperationSuccess extends ManagementState {
  final String message;

  const ManagementOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ManagementError extends ManagementState {
  final String message;

  const ManagementError({required this.message});

  @override
  List<Object?> get props => [message];
}
