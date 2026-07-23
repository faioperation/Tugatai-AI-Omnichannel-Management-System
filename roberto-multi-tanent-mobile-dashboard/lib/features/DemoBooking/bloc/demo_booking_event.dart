import 'package:equatable/equatable.dart';

abstract class DemoBookingEvent extends Equatable {
  const DemoBookingEvent();

  @override
  List<Object> get props => [];
}

class FetchDemoBookings extends DemoBookingEvent {
  final int page;
  final int limit;

  const FetchDemoBookings({this.page = 1, this.limit = 20});

  @override
  List<Object> get props => [page, limit];
}

class UpdateDemoBookingStatus extends DemoBookingEvent {
  final String id;
  final String status;

  const UpdateDemoBookingStatus(this.id, this.status);

  @override
  List<Object> get props => [id, status];
}

class DeleteDemoBooking extends DemoBookingEvent {
  final String id;

  const DeleteDemoBooking(this.id);

  @override
  List<Object> get props => [id];
}
