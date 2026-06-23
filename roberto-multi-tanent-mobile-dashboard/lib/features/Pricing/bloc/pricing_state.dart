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

  const PricingLoaded({required this.rules});

  @override
  List<Object> get props => [rules];
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
