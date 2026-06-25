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

// Branch Events
class FetchBranchesRequested extends ManagementEvent {}

class CreateBranchRequested extends ManagementEvent {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String managerId;

  const CreateBranchRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.managerId,
  });

  @override
  List<Object?> get props => [name, email, phone, address, managerId];
}

class UpdateBranchRequested extends ManagementEvent {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String managerId;

  const UpdateBranchRequested({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.managerId,
  });

  @override
  List<Object?> get props => [id, name, email, phone, address, managerId];
}

class DeleteBranchRequested extends ManagementEvent {
  final String id;

  const DeleteBranchRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

