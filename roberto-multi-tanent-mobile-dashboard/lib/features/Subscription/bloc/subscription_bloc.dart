import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Subscription/data/repositories/subscription_repository.dart';

import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;

  SubscriptionBloc({required this.subscriptionRepository}) : super(SubscriptionInitial()) {
    on<FetchSubscriptionsRequested>(_onFetchSubscriptionsRequested);
  }

  Future<void> _onFetchSubscriptionsRequested(
    FetchSubscriptionsRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final subscriptionData = await subscriptionRepository.getSystemOwnerSubscriptions();
      emit(SubscriptionLoaded(subscriptionData: subscriptionData));
    } catch (e) {
      emit(SubscriptionError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
