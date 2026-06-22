abstract class CampaignEvent {}

class FetchCampaigns extends CampaignEvent {}

class CreateCampaign extends CampaignEvent {
  final String name;
  final String branchId;
  final String message;
  final DateTime endDate;

  CreateCampaign({
    required this.name,
    required this.branchId,
    required this.message,
    required this.endDate,
  });
}

class UpdateCampaign extends CampaignEvent {
  final String id;
  final String? name;
  final String? branchId;
  final String? message;
  final DateTime? endDate;

  UpdateCampaign({
    required this.id,
    this.name,
    this.branchId,
    this.message,
    this.endDate,
  });
}

class DeleteCampaign extends CampaignEvent {
  final String id;

  DeleteCampaign({required this.id});
}
