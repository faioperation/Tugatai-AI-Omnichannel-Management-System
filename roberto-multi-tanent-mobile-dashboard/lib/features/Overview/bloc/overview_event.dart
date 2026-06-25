import 'package:equatable/equatable.dart';

abstract class OverviewEvent extends Equatable {
  const OverviewEvent();

  @override
  List<Object?> get props => [];
}

class FetchSystemOverviewRequested extends OverviewEvent {}

class FetchBusinessOverviewRequested extends OverviewEvent {
  final String? branchId;
  const FetchBusinessOverviewRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}

class FetchBranchManagerOverviewRequested extends OverviewEvent {}
