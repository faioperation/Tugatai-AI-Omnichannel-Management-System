import 'package:equatable/equatable.dart';

abstract class OverviewEvent extends Equatable {
  const OverviewEvent();

  @override
  List<Object?> get props => [];
}

class FetchSystemOverviewRequested extends OverviewEvent {}

class FetchBusinessOverviewRequested extends OverviewEvent {}
