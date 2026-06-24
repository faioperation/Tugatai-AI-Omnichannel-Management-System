import 'package:equatable/equatable.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<OrderMod> bookings;
  final int total;
  final int totalPages;
  final int currentPage;

  const BookingLoaded({
    required this.bookings,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [bookings, total, totalPages, currentPage];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingActionSuccess extends BookingState {
  final String message;

  const BookingActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
