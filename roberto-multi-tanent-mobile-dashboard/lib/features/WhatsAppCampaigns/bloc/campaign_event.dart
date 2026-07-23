abstract class CampaignEvent {}

class FetchCampaigns extends CampaignEvent {
  final String? branchId;
  FetchCampaigns({this.branchId});
}

class CreateCampaign extends CampaignEvent {
  final String title;
  final String message;
  final String branchId;
  final List<String> selectedPeople;
  final DateTime scheduledTime;
  final DateTime endDate;
  final String? country;
  final String? productType;

  CreateCampaign({
    required this.title,
    required this.message,
    required this.branchId,
    required this.selectedPeople,
    required this.scheduledTime,
    required this.endDate,
    this.country,
    this.productType,
  });
}

class UpdateCampaign extends CampaignEvent {
  final String id;
  final String? title;
  final String? message;
  final String? branchId;
  final List<String>? selectedPeople;
  final DateTime? scheduledTime;
  final DateTime? endDate;
  final String? country;
  final String? productType;

  UpdateCampaign({
    required this.id,
    this.title,
    this.message,
    this.branchId,
    this.selectedPeople,
    this.scheduledTime,
    this.endDate,
    this.country,
    this.productType,
  });
}

class DeleteCampaign extends CampaignEvent {
  final String id;

  DeleteCampaign({required this.id});
}
