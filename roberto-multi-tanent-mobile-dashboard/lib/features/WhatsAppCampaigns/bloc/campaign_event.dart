abstract class CampaignEvent {}

class FetchCampaigns extends CampaignEvent {}

class CreateCampaign extends CampaignEvent {
  final String title;
  final String audience;
  final String inboxId;
  final List<String> selectedPeople;

  CreateCampaign({
    required this.title,
    required this.audience,
    required this.inboxId,
    required this.selectedPeople,
  });
}

class UpdateCampaign extends CampaignEvent {
  final String id;
  final String? title;
  final String? audience;
  final String? inboxId;
  final List<String>? selectedPeople;

  UpdateCampaign({
    required this.id,
    this.title,
    this.audience,
    this.inboxId,
    this.selectedPeople,
  });
}

class DeleteCampaign extends CampaignEvent {
  final String id;

  DeleteCampaign({required this.id});
}
