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
  
  final int totalBookings;
  final int pending;
  final int confirmed;
  final int delivered;

  const BookingLoaded({
    required this.bookings,
    required this.total,
    required this.totalPages,
    required this.currentPage,
    this.totalBookings = 0,
    this.pending = 0,
    this.confirmed = 0,
    this.delivered = 0,
  });

  @override
  List<Object?> get props => [bookings, total, totalPages, currentPage, totalBookings, pending, confirmed, delivered];
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
