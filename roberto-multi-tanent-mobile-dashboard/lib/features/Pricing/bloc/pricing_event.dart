import 'package:equatable/equatable.dart';
import 'package:roberto/common/user_role.dart';
import 'package:roberto/features/Pricing/widget/pricing_rule_mod.dart';

abstract class PricingEvent extends Equatable {
  const PricingEvent();

  @override
  List<Object?> get props => [];
}

class FetchPricingRules extends PricingEvent {
  final int page;
  final int limit;
  final UserRole role;

  const FetchPricingRules({
    this.page = 1,
    this.limit = 10,
    this.role = UserRole.businessOwner,
  });

  @override
  List<Object> get props => [page, limit, role];
}

class CreatePricingRule extends PricingEvent {
  final String ruleName;
  final String type;
  final Map<String, dynamic> configuration;
  final bool status;
  final UserRole role;

  const CreatePricingRule({
    required this.ruleName,
    required this.type,
    required this.configuration,
    this.status = true,
    this.role = UserRole.businessOwner,
  });

  @override
  List<Object> get props => [ruleName, type, configuration, status, role];
}

class UpdatePricingRule extends PricingEvent {
  final String id;
  final String? ruleName;
  final String? type;
  final Map<String, dynamic>? configuration;
  final bool? status;
  final UserRole role;

  const UpdatePricingRule({
    required this.id,
    this.ruleName,
    this.type,
    this.configuration,
    this.status,
    this.role = UserRole.businessOwner,
  });

  @override
  List<Object?> get props => [id, ruleName, type, configuration, status, role];
}

class DeletePricingRule extends PricingEvent {
  final String id;
  final UserRole role;

  const DeletePricingRule({
    required this.id,
    this.role = UserRole.businessOwner,
  });

  @override
  List<Object> get props => [id, role];
}
