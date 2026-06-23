import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/Pricing/data/repositories/pricing_repository.dart';
import 'package:roberto/common/user_role.dart';
import 'package:roberto/features/Pricing/widget/pricing_rule_mod.dart';
import 'pricing_event.dart';
import 'pricing_state.dart';

class PricingBloc extends Bloc<PricingEvent, PricingState> {
  final PricingRepository pricingRepository;

  PricingBloc({required this.pricingRepository}) : super(PricingInitial()) {
    on<FetchPricingRules>(_onFetchPricingRules);
    on<CreatePricingRule>(_onCreatePricingRule);
    on<UpdatePricingRule>(_onUpdatePricingRule);
    on<DeletePricingRule>(_onDeletePricingRule);
  }

  Future<void> _onFetchPricingRules(FetchPricingRules event, Emitter<PricingState> emit) async {
    emit(PricingLoading());
    try {
      final response = await pricingRepository.getPricingRules(
        page: event.page,
        limit: event.limit,
        isBranchManager: event.role == UserRole.branchManager,
      );

      if (response['success'] == true) {
        final data = response['data']['data'] as List?;
        final rules = (data ?? []).map((e) => PricingRuleMod.fromJson(e)).toList();
        emit(PricingLoaded(rules: rules));
      } else {
        emit(PricingError(message: response['message'] ?? 'Failed to load pricing rules'));
      }
    } catch (e) {
      emit(PricingError(message: e.toString()));
    }
  }

  Future<void> _onCreatePricingRule(CreatePricingRule event, Emitter<PricingState> emit) async {
    emit(PricingActionLoading());
    try {
      final response = await pricingRepository.createPricingRule(
        ruleName: event.ruleName,
        type: event.type,
        configuration: event.configuration,
        status: event.status,
        branchId: event.branchId,
        isBranchManager: event.role == UserRole.branchManager,
      );

      if (response['success'] == true) {
        emit(PricingActionSuccess(message: response['message'] ?? 'Pricing rule created successfully'));
        add(FetchPricingRules(role: event.role));
      } else {
        emit(PricingError(message: response['message'] ?? 'Failed to create pricing rule'));
      }
    } catch (e) {
      emit(PricingError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePricingRule(UpdatePricingRule event, Emitter<PricingState> emit) async {
    emit(PricingActionLoading());
    try {
      final response = await pricingRepository.updatePricingRule(
        id: event.id,
        ruleName: event.ruleName,
        type: event.type,
        configuration: event.configuration,
        status: event.status,
        branchId: event.branchId,
        isBranchManager: event.role == UserRole.branchManager,
      );

      if (response['success'] == true) {
        emit(PricingActionSuccess(message: response['message'] ?? 'Pricing rule updated successfully'));
        add(FetchPricingRules(role: event.role));
      } else {
        emit(PricingError(message: response['message'] ?? 'Failed to update pricing rule'));
      }
    } catch (e) {
      emit(PricingError(message: e.toString()));
    }
  }

  Future<void> _onDeletePricingRule(DeletePricingRule event, Emitter<PricingState> emit) async {
    emit(PricingActionLoading());
    try {
      final response = await pricingRepository.deletePricingRule(
        id: event.id,
        isBranchManager: event.role == UserRole.branchManager,
      );

      if (response['success'] == true) {
        emit(PricingActionSuccess(message: response['message'] ?? 'Pricing rule deleted successfully'));
        add(FetchPricingRules(role: event.role));
      } else {
        emit(PricingError(message: response['message'] ?? 'Failed to delete pricing rule'));
      }
    } catch (e) {
      emit(PricingError(message: e.toString()));
    }
  }
}
