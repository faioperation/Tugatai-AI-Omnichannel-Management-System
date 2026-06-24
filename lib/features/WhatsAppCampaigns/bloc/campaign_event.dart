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

  CreateCampaign({
    required this.title,
    required this.message,
    required this.branchId,
    required this.selectedPeople,
    required this.scheduledTime,
    required this.endDate,
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

  UpdateCampaign({
    required this.id,
    this.title,
    this.message,
    this.branchId,
    this.selectedPeople,
    this.scheduledTime,
    this.endDate,
  });
}

class DeleteCampaign extends CampaignEvent {
  final String id;

  DeleteCampaign({required this.id});
}
