import 'package:equatable/equatable.dart';

abstract class ManagementEvent extends Equatable {
  const ManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchBranchManagersRequested extends ManagementEvent {}

class CreateBranchManagerRequested extends ManagementEvent {
  final String name;
  final String email;
  final String password;

  const CreateBranchManagerRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class DeleteBranchManagerRequested extends ManagementEvent {
  final String id;

  const DeleteBranchManagerRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
