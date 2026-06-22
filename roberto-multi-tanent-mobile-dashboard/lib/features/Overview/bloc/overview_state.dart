import 'package:equatable/equatable.dart';
import 'package:roberto/features/Overview/data/models/system_overview_model.dart';

abstract class OverviewState extends Equatable {
  const OverviewState();

  @override
  List<Object?> get props => [];
}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class SystemOverviewLoaded extends OverviewState {
  final SystemOverviewModel overviewData;

  const SystemOverviewLoaded({required this.overviewData});

  @override
  List<Object?> get props => [overviewData];
}

class OverviewError extends OverviewState {
  final String message;

  const OverviewError({required this.message});

  @override
  List<Object?> get props => [message];
}
