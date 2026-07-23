import 'package:equatable/equatable.dart';
import 'package:roberto/features/businesssubscription/data/models/business_subscription_model.dart';

abstract class BusinessSubscriptionState extends Equatable {
  const BusinessSubscriptionState();

  @override
  List<Object?> get props => [];
}

class BusinessSubscriptionInitial extends BusinessSubscriptionState {}

class BusinessSubscriptionLoading extends BusinessSubscriptionState {}

class BusinessSubscriptionLoaded extends BusinessSubscriptionState {
  final List<BusinessSubscriptionModel> subscriptions;

  const BusinessSubscriptionLoaded({required this.subscriptions});

  @override
  List<Object?> get props => [subscriptions];
}

class BusinessSubscriptionError extends BusinessSubscriptionState {
  final String message;

  const BusinessSubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CheckoutSessionLoading extends BusinessSubscriptionState {}

class CheckoutSessionSuccess extends BusinessSubscriptionState {
  final String url;

  const CheckoutSessionSuccess({required this.url});

  @override
  List<Object?> get props => [url];
}
