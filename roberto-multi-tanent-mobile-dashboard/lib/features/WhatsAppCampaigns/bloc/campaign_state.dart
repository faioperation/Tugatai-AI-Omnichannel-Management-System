import 'package:roberto/features/WhatsAppCampaigns/data/models/campaign_model.dart';

abstract class CampaignState {}

class CampaignInitial extends CampaignState {}

class CampaignLoading extends CampaignState {}

class CampaignLoaded extends CampaignState {
  final List<CampaignModel> campaigns;

  CampaignLoaded({required this.campaigns});
}

class CampaignActionSuccess extends CampaignState {
  final String message;

  CampaignActionSuccess({required this.message});
}

class CampaignError extends CampaignState {
  final String message;

  CampaignError({required this.message});
}
