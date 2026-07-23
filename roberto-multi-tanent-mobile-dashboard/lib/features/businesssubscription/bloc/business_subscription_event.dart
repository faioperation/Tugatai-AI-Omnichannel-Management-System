import 'package:equatable/equatable.dart';

abstract class BusinessSubscriptionEvent extends Equatable {
  const BusinessSubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class FetchMySubscriptionRequested extends BusinessSubscriptionEvent {}

class CreateCheckoutSessionRequested extends BusinessSubscriptionEvent {
  final String planId;
  final String billingCycle;

  const CreateCheckoutSessionRequested({
    required this.planId,
    required this.billingCycle,
  });

  @override
  List<Object?> get props => [planId, billingCycle];
}
