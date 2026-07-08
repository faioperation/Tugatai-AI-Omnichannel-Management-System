import 'package:equatable/equatable.dart';
import 'package:roberto/features/DemoBooking/data/models/demo_booking_model.dart';

abstract class DemoBookingState extends Equatable {
  const DemoBookingState();

  @override
  List<Object?> get props => [];
}

class DemoBookingInitial extends DemoBookingState {}

class DemoBookingLoading extends DemoBookingState {}

class DemoBookingLoaded extends DemoBookingState {
  final List<DemoBookingModel> bookings;
  final int totalPages;
  final int currentPage;

  const DemoBookingLoaded({
    required this.bookings,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [bookings, totalPages, currentPage];
}

class DemoBookingError extends DemoBookingState {
  final String message;

  const DemoBookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class DemoBookingActionLoading extends DemoBookingState {}

class DemoBookingActionSuccess extends DemoBookingState {
  final String message;

  const DemoBookingActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DemoBookingActionError extends DemoBookingState {
  final String message;

  const DemoBookingActionError(this.message);

  @override
  List<Object?> get props => [message];
}
