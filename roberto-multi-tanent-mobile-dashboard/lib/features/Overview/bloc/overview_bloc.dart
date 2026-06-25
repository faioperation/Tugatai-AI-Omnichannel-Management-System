import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Overview/data/repositories/overview_repository.dart';

import 'overview_event.dart';
import 'overview_state.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  final OverviewRepository overviewRepository;

  OverviewBloc({required this.overviewRepository}) : super(OverviewInitial()) {
    on<FetchSystemOverviewRequested>(_onFetchSystemOverviewRequested);
    on<FetchBusinessOverviewRequested>(_onFetchBusinessOverviewRequested);
    on<FetchBranchManagerOverviewRequested>(_onFetchBranchManagerOverviewRequested);
  }

  Future<void> _onFetchSystemOverviewRequested(
    FetchSystemOverviewRequested event,
    Emitter<OverviewState> emit,
  ) async {
    emit(OverviewLoading());
    try {
      final overviewData = await overviewRepository.getSystemOwnerOverview();
      emit(SystemOverviewLoaded(overviewData: overviewData));
    } catch (e) {
      emit(OverviewError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchBusinessOverviewRequested(
    FetchBusinessOverviewRequested event,
    Emitter<OverviewState> emit,
  ) async {
    emit(OverviewLoading());
    try {
      final businessData = await overviewRepository.getBusinessOwnerOverview(branchId: event.branchId);
      emit(BusinessOverviewLoaded(businessData: businessData));
    } catch (e) {
      emit(OverviewError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchBranchManagerOverviewRequested(
    FetchBranchManagerOverviewRequested event,
    Emitter<OverviewState> emit,
  ) async {
    emit(OverviewLoading());
    try {
      final businessData = await overviewRepository.getBranchManagerOverview();
      emit(BranchManagerOverviewLoaded(businessData: businessData));
    } catch (e) {
      emit(OverviewError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
