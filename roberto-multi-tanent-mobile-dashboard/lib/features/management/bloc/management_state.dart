import 'package:equatable/equatable.dart';
import 'package:roberto/features/management/data/models/branch_manager_model.dart';
import 'package:roberto/features/management/data/models/branch_model.dart';

abstract class ManagementState extends Equatable {
  const ManagementState();

  @override
  List<Object?> get props => [];
}

class ManagementInitial extends ManagementState {}

class ManagementLoading extends ManagementState {}

class ManagementLoaded extends ManagementState {
  final List<BranchManagerModel> managers;
  final List<BranchModel> branches;

  const ManagementLoaded({required this.managers, required this.branches});

  @override
  List<Object?> get props => [managers, branches];
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
