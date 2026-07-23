import 'package:equatable/equatable.dart';
import 'package:roberto/features/CRM/data/models/crm_lead_model.dart';

abstract class CrmState extends Equatable {
  const CrmState();

  @override
  List<Object?> get props => [];
}

class CrmInitial extends CrmState {}

class CrmLoading extends CrmState {}

class CrmLeadsLoaded extends CrmState {
  final List<CrmLeadModel> leads;
  final Map<String, dynamic>? meta;

  const CrmLeadsLoaded({required this.leads, this.meta});

  @override
  List<Object?> get props => [leads, meta];
}

class CrmActionLoading extends CrmState {}

class CrmActionSuccess extends CrmState {
  final String message;

  const CrmActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class CrmError extends CrmState {
  final String message;

  const CrmError({required this.message});

  @override
  List<Object> get props => [message];
}
