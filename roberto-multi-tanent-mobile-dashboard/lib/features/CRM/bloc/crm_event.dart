import 'package:equatable/equatable.dart';
import 'package:roberto/common/user_role.dart';

abstract class CrmEvent extends Equatable {
  const CrmEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeads extends CrmEvent {
  final String branchId;
  final int page;
  final int limit;
  final String searchParam;
  final UserRole role;
  final String country;
  final String productType;

  const FetchLeads({
    required this.branchId,
    this.page = 1,
    this.limit = 10,
    this.searchParam = '',
    this.role = UserRole.businessOwner,
    this.country = '',
    this.productType = '',
  });

  @override
  List<Object> get props => [branchId, page, limit, searchParam, role, country, productType];
}

class CreateLead extends CrmEvent {
  final String branchId;
  final String name;
  final String email;
  final String phone;
  final String source;
  final String country;
  final String address;
  final String note;
  final String status;
  final Map<String, dynamic>? metadata;
  final UserRole role;

  const CreateLead({
    required this.branchId,
    required this.name,
    required this.email,
    required this.phone,
    required this.source,
    this.country = '',
    required this.address,
    required this.note,
    required this.status,
    this.metadata,
    this.role = UserRole.businessOwner,
  });

  @override
  List<Object?> get props => [branchId, name, email, phone, source, country, address, note, status, metadata, role];
}

class UpdateLead extends CrmEvent {
  final String id;
  final String? branchId;
  final String? name;
  final String? email;
  final String? phone;
  final String? source;
  final String? address;
  final String? note;
  final String? status;
  final Map<String, dynamic>? metadata;
  final UserRole role;

  const UpdateLead({
    required this.id,
    this.branchId,
    this.name,
    this.email,
    this.phone,
    this.source,
    this.address,
    this.note,
    this.status,
    this.metadata,
    this.role = UserRole.businessOwner,
  });

  @override
  List<Object?> get props => [id, branchId, name, email, phone, source, address, note, status, metadata, role];
}

class DeleteLead extends CrmEvent {
  final String id;
  final String branchId;
  final UserRole role;

  const DeleteLead({
    required this.id,
    required this.branchId,
    this.role = UserRole.businessOwner,
  });

  @override
  List<Object> get props => [id, branchId, role];
}
