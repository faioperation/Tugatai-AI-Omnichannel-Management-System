import 'package:equatable/equatable.dart';
import 'package:roberto/features/Subscription/data/models/subscription_model.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final SystemOwnerSubscriptionModel subscriptionData;

  const SubscriptionLoaded({required this.subscriptionData});

  @override
  List<Object?> get props => [subscriptionData];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}
