import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_event.dart';
import 'package:roberto/features/businesssubscription/bloc/business_subscription_state.dart';
import 'package:roberto/features/businesssubscription/data/repositories/business_subscription_repository.dart';

class BusinessSubscriptionBloc extends Bloc<BusinessSubscriptionEvent, BusinessSubscriptionState> {
  final BusinessSubscriptionRepository repository;

  BusinessSubscriptionBloc({required this.repository}) : super(BusinessSubscriptionInitial()) {
    on<FetchMySubscriptionRequested>(_onFetchMySubscription);
    on<CreateCheckoutSessionRequested>(_onCreateCheckoutSession);
  }

  Future<void> _onFetchMySubscription(
    FetchMySubscriptionRequested event,
    Emitter<BusinessSubscriptionState> emit,
  ) async {
    emit(BusinessSubscriptionLoading());
    try {
      final subscriptions = await repository.getMySubscription();
      emit(BusinessSubscriptionLoaded(subscriptions: subscriptions));
    } catch (e) {
      emit(BusinessSubscriptionError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateCheckoutSession(
    CreateCheckoutSessionRequested event,
    Emitter<BusinessSubscriptionState> emit,
  ) async {
    emit(CheckoutSessionLoading());
    try {
      final url = await repository.createCheckoutSession(
        planId: event.planId,
        billingCycle: event.billingCycle,
      );
      emit(CheckoutSessionSuccess(url: url));
    } catch (e) {
      emit(BusinessSubscriptionError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
