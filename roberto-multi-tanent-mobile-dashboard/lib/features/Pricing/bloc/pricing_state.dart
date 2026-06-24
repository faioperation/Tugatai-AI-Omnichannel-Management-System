import 'package:equatable/equatable.dart';
import 'package:roberto/features/Pricing/widget/pricing_rule_mod.dart';

abstract class PricingState extends Equatable {
  const PricingState();

  @override
  List<Object?> get props => [];
}

class PricingInitial extends PricingState {}

class PricingLoading extends PricingState {}

class PricingLoaded extends PricingState {
  final List<PricingRuleMod> rules;
  final int total;
  final int activeCount;
  final int typeCounts;

  const PricingLoaded({
    required this.rules,
    this.total = 0,
    this.activeCount = 0,
    this.typeCounts = 0,
  });

  @override
  List<Object> get props => [rules, total, activeCount, typeCounts];
}

class PricingError extends PricingState {
  final String message;

  const PricingError({required this.message});

  @override
  List<Object> get props => [message];
}

class PricingActionLoading extends PricingState {}

class PricingActionSuccess extends PricingState {
  final String message;

  const PricingActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
