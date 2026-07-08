import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/DemoBooking/bloc/demo_booking_event.dart';
import 'package:roberto/features/DemoBooking/bloc/demo_booking_state.dart';
import 'package:roberto/features/DemoBooking/data/repositories/demo_booking_repository.dart';

class DemoBookingBloc extends Bloc<DemoBookingEvent, DemoBookingState> {
  final DemoBookingRepository repository;
  
  // Track current state to refresh after update/delete
  int _lastPage = 1;
  int _lastLimit = 20;

  DemoBookingBloc({required this.repository}) : super(DemoBookingInitial()) {
    on<FetchDemoBookings>(_onFetchDemoBookings);
    on<UpdateDemoBookingStatus>(_onUpdateDemoBookingStatus);
    on<DeleteDemoBooking>(_onDeleteDemoBooking);
  }

  Future<void> _onFetchDemoBookings(FetchDemoBookings event, Emitter<DemoBookingState> emit) async {
    emit(DemoBookingLoading());
    try {
      _lastPage = event.page;
      _lastLimit = event.limit;
      final response = await repository.getDemoBookings(page: event.page, limit: event.limit);
      emit(DemoBookingLoaded(
        bookings: response.bookings,
        totalPages: response.totalPages,
        currentPage: response.currentPage,
      ));
    } catch (e) {
      emit(DemoBookingError(e.toString()));
    }
  }

  Future<void> _onUpdateDemoBookingStatus(UpdateDemoBookingStatus event, Emitter<DemoBookingState> emit) async {
    final currentState = state;
    emit(DemoBookingActionLoading());
    try {
      await repository.updateDemoBookingStatus(event.id, event.status);
      emit(const DemoBookingActionSuccess('Demo booking status updated successfully'));
    } catch (e) {
      emit(DemoBookingActionError(e.toString()));
    }
    
    // Always return to the loaded state if it existed, then re-fetch
    if (currentState is DemoBookingLoaded) {
      emit(currentState);
      add(FetchDemoBookings(page: _lastPage, limit: _lastLimit));
    }
  }

  Future<void> _onDeleteDemoBooking(DeleteDemoBooking event, Emitter<DemoBookingState> emit) async {
    final currentState = state;
    emit(DemoBookingActionLoading());
    try {
      await repository.deleteDemoBooking(event.id);
      emit(const DemoBookingActionSuccess('Demo booking deleted successfully'));
    } catch (e) {
      emit(DemoBookingActionError(e.toString()));
    }
    
    if (currentState is DemoBookingLoaded) {
      emit(currentState);
      add(FetchDemoBookings(page: _lastPage, limit: _lastLimit));
    }
  }
}
