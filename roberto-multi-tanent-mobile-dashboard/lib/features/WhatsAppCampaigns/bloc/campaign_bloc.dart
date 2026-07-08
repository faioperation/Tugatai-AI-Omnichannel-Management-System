import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/WhatsAppCampaigns/bloc/campaign_event.dart';
import 'package:roberto/features/WhatsAppCampaigns/bloc/campaign_state.dart';
import 'package:roberto/features/WhatsAppCampaigns/data/repositories/campaign_repository.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final CampaignRepository _campaignRepository;

  CampaignBloc({required CampaignRepository campaignRepository})
      : _campaignRepository = campaignRepository,
        super(CampaignInitial()) {
    on<FetchCampaigns>(_onFetchCampaigns);
    on<CreateCampaign>(_onCreateCampaign);
    on<UpdateCampaign>(_onUpdateCampaign);
    on<DeleteCampaign>(_onDeleteCampaign);
  }

  Future<void> _onFetchCampaigns(
    FetchCampaigns event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      final campaigns = await _campaignRepository.getCampaigns(branchId: event.branchId);
      emit(CampaignLoaded(campaigns: campaigns));
    } catch (e) {
      emit(CampaignError(message: e.toString()));
    }
  }

  Future<void> _onCreateCampaign(
    CreateCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      await _campaignRepository.createCampaign(
        title: event.title,
        message: event.message,
        branchId: event.branchId,
        selectedPeople: event.selectedPeople,
        scheduledTime: event.scheduledTime,
        endDate: event.endDate,
      );
      emit(CampaignActionSuccess(message: 'Campaign created successfully'));
      add(FetchCampaigns());
    } catch (e) {
      emit(CampaignError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCampaign(
    UpdateCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      await _campaignRepository.updateCampaign(
        id: event.id,
        title: event.title,
        message: event.message,
        branchId: event.branchId,
        selectedPeople: event.selectedPeople,
        scheduledTime: event.scheduledTime,
        endDate: event.endDate,
      );
      emit(CampaignActionSuccess(message: 'Campaign updated successfully'));
      add(FetchCampaigns());
    } catch (e) {
      emit(CampaignError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCampaign(
    DeleteCampaign event,
    Emitter<CampaignState> emit,
  ) async {
    emit(CampaignLoading());
    try {
      await _campaignRepository.deleteCampaign(event.id);
      emit(CampaignActionSuccess(message: 'Campaign deleted successfully'));
      add(FetchCampaigns());
    } catch (e) {
      emit(CampaignError(message: e.toString()));
    }
  }
}
