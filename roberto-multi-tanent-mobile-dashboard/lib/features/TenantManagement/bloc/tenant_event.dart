import 'package:equatable/equatable.dart';

abstract class TenantEvent extends Equatable {
  const TenantEvent();

  @override
  List<Object?> get props => [];
}

class FetchTenantsRequested extends TenantEvent {
  final String? searchParam;

  const FetchTenantsRequested({this.searchParam});

  @override
  List<Object?> get props => [searchParam];
}

class CreateTenantRequested extends TenantEvent {
  final Map<String, dynamic> payload;

  const CreateTenantRequested({required this.payload});

  @override
  List<Object?> get props => [payload];
}

class UpdateTenantRequested extends TenantEvent {
  final String businessId;
  final Map<String, dynamic> payload;

  const UpdateTenantRequested({required this.businessId, required this.payload});

  @override
  List<Object?> get props => [businessId, payload];
}

class DeleteTenantRequested extends TenantEvent {
  final String businessId;

  const DeleteTenantRequested({required this.businessId});

  @override
  List<Object?> get props => [businessId];
}
