import 'package:equatable/equatable.dart';
import 'package:roberto/features/TenantManagement%20/data/models/tenant_model.dart';

abstract class TenantState extends Equatable {
  const TenantState();

  @override
  List<Object?> get props => [];
}

class TenantInitial extends TenantState {}

class TenantLoading extends TenantState {}

class TenantLoaded extends TenantState {
  final TenantResponse tenantResponse;

  const TenantLoaded({required this.tenantResponse});

  @override
  List<Object?> get props => [tenantResponse];
}

class TenantError extends TenantState {
  final String message;

  const TenantError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TenantActionLoading extends TenantState {}

class TenantActionSuccess extends TenantState {
  final String message;

  const TenantActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
