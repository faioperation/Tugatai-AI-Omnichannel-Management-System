import 'package:equatable/equatable.dart';

abstract class BusinessSubscriptionEvent extends Equatable {
  const BusinessSubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class FetchMySubscriptionRequested extends BusinessSubscriptionEvent {}
