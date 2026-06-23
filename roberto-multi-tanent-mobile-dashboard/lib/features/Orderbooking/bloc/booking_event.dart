import 'package:equatable/equatable.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class GetBookings extends BookingEvent {
  final int page;
  final int limit;
  final String search;
  final String status;
  final String branchId;

  const GetBookings({
    this.page = 1,
    this.limit = 10,
    this.search = '',
    this.status = '',
    required this.branchId,
  });

  @override
  List<Object?> get props => [page, limit, search, status, branchId];
}

class CreateBooking extends BookingEvent {
  final Map<String, dynamic> payload;
  final String branchId;

  const CreateBooking({required this.payload, required this.branchId});

  @override
  List<Object?> get props => [payload, branchId];
}

class UpdateBooking extends BookingEvent {
  final String id;
  final Map<String, dynamic> payload;
  final String branchId;

  const UpdateBooking({required this.id, required this.payload, required this.branchId});

  @override
  List<Object?> get props => [id, payload, branchId];
}

class DeleteBooking extends BookingEvent {
  final String id;
  final String branchId;

  const DeleteBooking({required this.id, required this.branchId});

  @override
  List<Object?> get props => [id, branchId];
}
