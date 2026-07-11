import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Orderbooking/bloc/booking_event.dart';
import 'package:roberto/features/Orderbooking/bloc/booking_state.dart';
import 'package:roberto/features/Orderbooking/data/repositories/booking_repository.dart';
import 'package:roberto/features/Orderbooking/widget/order_mod.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;

  // Track last used filter params so refresh after action preserves filters
  GetBookings? _lastGetBookings;

  BookingBloc({required this.repository}) : super(BookingInitial()) {
    on<GetBookings>(_onGetBookings);
    on<CreateBooking>(_onCreateBooking);
    on<UpdateBooking>(_onUpdateBooking);
    on<DeleteBooking>(_onDeleteBooking);
  }

  Future<void> _onGetBookings(GetBookings event, Emitter<BookingState> emit) async {
    _lastGetBookings = event; // Remember the last filter state
    emit(BookingLoading());
    try {
      final response = await repository.getBookings(
        page: event.page,
        limit: event.limit,
        search: event.search,
        status: event.status,
        branchId: event.branchId,
        country: event.country,
        productType: event.productType,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final bookings = data.map((e) => OrderMod.fromJson(e)).toList();

        final meta = response['meta'] ?? {};
        emit(BookingLoaded(
          bookings: bookings,
          total: meta['total'] ?? bookings.length,
          totalPages: meta['totalPage'] ?? 1,
          currentPage: meta['page'] ?? 1,
          totalBookings: meta['totalBookings'] ?? 0,
          pending: meta['pending'] ?? 0,
          confirmed: meta['confirmed'] ?? 0,
          delivered: meta['delivered'] ?? 0,
        ));
      } else {
        emit(BookingError(response['message'] ?? 'Failed to load bookings'));
      }
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  /// Refresh using last-known filter params so table stays consistent
  void _refreshWithFilters(String branchId) {
    final last = _lastGetBookings;
    add(GetBookings(
      branchId: branchId,
      page: last?.page ?? 1,
      limit: last?.limit ?? 10,
      search: last?.search ?? '',
      status: last?.status ?? '',
      country: last?.country ?? '',
      productType: last?.productType ?? '',
    ));
  }

  Future<void> _onCreateBooking(CreateBooking event, Emitter<BookingState> emit) async {
    try {
      final response = await repository.createBooking(event.payload);
      if (response['success'] == true) {
        emit(BookingActionSuccess(response['message'] ?? 'Booking created successfully'));
        _refreshWithFilters(event.branchId);
      } else {
        emit(BookingError(response['message'] ?? 'Failed to create booking'));
      }
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onUpdateBooking(UpdateBooking event, Emitter<BookingState> emit) async {
    try {
      final payload = Map<String, dynamic>.from(event.payload);
      if (event.branchId.isNotEmpty) {
        payload['branchId'] = event.branchId;
      }
      final response = await repository.updateBooking(event.id, payload);
      if (response['success'] == true) {
        emit(BookingActionSuccess(response['message'] ?? 'Booking updated successfully'));
        _refreshWithFilters(event.branchId);
      } else {
        emit(BookingError(response['message'] ?? 'Failed to update booking'));
      }
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onDeleteBooking(DeleteBooking event, Emitter<BookingState> emit) async {
    try {
      await repository.deleteBooking(event.id);
      emit(const BookingActionSuccess('Booking deleted successfully'));
      _refreshWithFilters(event.branchId);
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
