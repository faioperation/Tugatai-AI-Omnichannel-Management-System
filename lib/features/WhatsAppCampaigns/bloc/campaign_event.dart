abstract class CampaignEvent {}

class FetchCampaigns extends CampaignEvent {}

class CreateCampaign extends CampaignEvent {
  final String title;
  final String message;
  final String audience;
  final String inboxId;
  final List<String> selectedPeople;
  final DateTime scheduledTime;

  CreateCampaign({
    required this.title,
    required this.message,
    required this.audience,
    required this.inboxId,
    required this.selectedPeople,
    required this.scheduledTime,
  });
}

class UpdateCampaign extends CampaignEvent {
  final String id;
  final String? title;
  final String? message;
  final String? audience;
  final String? inboxId;
  final List<String>? selectedPeople;
  final DateTime? scheduledTime;

  UpdateCampaign({
    required this.id,
    this.title,
    this.message,
    this.audience,
    this.inboxId,
    this.selectedPeople,
    this.scheduledTime,
  });
}

class DeleteCampaign extends CampaignEvent {
  final String id;

  DeleteCampaign({required this.id});
}
